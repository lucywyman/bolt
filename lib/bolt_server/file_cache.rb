# frozen_string_literal: true

require 'concurrent'
require 'digest'
require 'fileutils'
require 'net/http'
require 'logging'

require 'bolt/error'

module BoltServer
  class FileCache
    class Error < Bolt::Error
      def initialize(msg)
        super(msg, 'bolt-server/file-cache-error')
      end
    end

    PURGE_TIMEOUT = 60 * 60
    PURGE_INTERVAL = 24 * PURGE_TIMEOUT
    PURGE_TTL = 7 * PURGE_INTERVAL

    def initialize(config,
                   executor: Concurrent::SingleThreadExecutor.new,
                   purge_interval: PURGE_INTERVAL,
                   purge_timeout: PURGE_TIMEOUT,
                   purge_ttl: PURGE_TTL)
      @executor = executor
      @cache_dir = config.cache_dir
      @config = config
      @logger = Logging.logger[self]
      @cache_dir_mutex = Concurrent::ReadWriteLock.new

      @purge = Concurrent::TimerTask.new(execution_interval: purge_interval,
                                         timeout_interval: purge_timeout,
                                         run_now: true) { expire(purge_ttl) }
      @purge.execute
    end

    def tmppath
      File.join(@cache_dir, 'tmp')
    end

    def setup
      FileUtils.mkdir_p(@cache_dir)
      FileUtils.mkdir_p(tmppath)
      self
    end

    def ssl_cert
      @ssl_cert ||= File.read(@config.ssl_cert)
    end

    def ssl_key
      @ssl_key ||= File.read(@config.ssl_key)
    end

    def client
      @client ||= begin
                    uri = URI(@config.file_server_uri)
                    https = Net::HTTP.new(uri.host, uri.port)
                    https.use_ssl = true
                    https.ssl_version = :TLSv1_2
                    https.ca_file = @config.ssl_ca_cert
                    https.cert = OpenSSL::X509::Certificate.new(ssl_cert)
                    https.key = OpenSSL::PKey::RSA.new(ssl_key)
                    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
                    https.open_timeout = @config.file_server_conn_timeout
                    https
                  end
    end

    def request_file(path, params, file)
      uri = "#{@config.file_server_uri.chomp('/')}#{path}"
      uri = URI(uri)
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)

      begin
        client.request(req) do |resp|
          if resp.code != "200"
            msg = "Failed to download task: #{resp.body}"
            @logger.warn resp.body
            raise Error, msg
          end
          resp.read_body do |chunk|
            file.write(chunk)
          end
        end
      rescue StandardError => e
        if e.is_a?(Bolt::Error)
          raise e
        else
          @logger.warn e
          raise Error, "Failed to download task: #{e.message}"
        end
      end
    ensure
      file.close
    end

    def check_file(file_path, sha)
      File.exist?(file_path) && Digest::SHA256.file(file_path) == sha
    end

    def serial_execute(&block)
      promise = Concurrent::Promise.new(executor: @executor, &block).execute.wait
      raise promise.reason if promise.rejected?
      promise.value
    end

    # Create a cache dir if necessary and update it's last write time. Returns the dir.
    # Acquires @cache_dir_mutex to ensure we don't try to purge the directory at the same time.
    # Uses the directory mtime because it's simpler to ensure the directory exists and update
    # mtime in a single place than with a file in a directory that may not exist.
    def create_cache_dir(sha)
      file_dir = File.join(@cache_dir, sha)
      @cache_dir_mutex.with_read_lock do
        # mkdir_p doesn't error if the file exists
        FileUtils.mkdir_p(file_dir, mode: 0o750)
        FileUtils.touch(file_dir)
      end
      file_dir
    end

    def download_file(file_path, sha, uri)
      if check_file(file_path, sha)
        @logger.debug("File was downloaded while queued: #{file_path}")
        return file_path
      end

      @logger.debug("Downloading file: #{file_path}")

      tmpfile = Tempfile.new(sha, tmppath)
      request_file(uri['path'], uri['params'], tmpfile)

      if Digest::SHA256.file(tmpfile.path) == sha
        # mv doesn't error if the file exists
        FileUtils.mv(tmpfile.path, file_path)
        @logger.debug("Downloaded file: #{file_path}")
        file_path
      else
        msg = "Downloaded file did not match checksum for: #{file_path}"
        @logger.warn msg
        raise Error, msg
      end
    end

    # If the file doesn't exist or is invalid redownload it
    # This downloads, validates and moves into place
    def update_file(file_data)
      sha = file_data['sha256']
      file_dir = create_cache_dir(file_data['sha256'])
      file_path = File.join(file_dir, File.basename(file_data['filename']))
      if check_file(file_path, sha)
        @logger.debug("Using prexisting task file: #{file_path}")
        return file_path
      end

      @logger.debug("Queueing download for: #{file_path}")
      serial_execute { download_file(file_path, sha, file_data['uri']) }
    end

    def expire(purge_ttl)
      expired_time = Time.now - purge_ttl
      @cache_dir_mutex.with_write_lock do
        Dir.glob(File.join(@cache_dir, '*')).select { |f| File.directory?(f) }.each do |dir|
          if (mtime = File.mtime(dir)) < expired_time
            @logger.debug("Removing #{dir}, last used at #{mtime}")
            FileUtils.remove_dir(dir)
          end
        end
      end
    end
  end
end
