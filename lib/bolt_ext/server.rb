# frozen_string_literal: true

require 'sinatra'
require 'bolt'
require 'bolt/task'
require 'json'

class TransportAPI < Sinatra::Base
  set :server, :puma

  post '/ssh/run_task' do
    body = JSON.parse(request.body.read)
    keys = %w[user password port ssh-key-content]
    opts = body['target'].select { |k, _| keys.include? k }
    opts.merge(body['target']['options'])
    target = [Bolt::Target.new(body['target']['hostname'], opts)]
    task = Bolt::Task.new(body['task'])
    parameters = body['parameters']

    executor = Bolt::Executor.new(Bolt::Config.new)

    # Since this will only be on one node we can just set r to the result
    executor.run_task(target, task, parameters) do |event|
      if event[:type] == :node_result
        @r = event[:result].to_json
      end
    end
    response.body = @r
    response.status = 200
  end
end
