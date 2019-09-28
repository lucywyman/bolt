# Installing Bolt

Packaged versions of Bolt are available for many modern Linux distributions, as well as macOS and Windows.

Have Questions? Get in touch. We're in `#bolt` on the [Puppet community Slack](https://slack.puppet.com/).

**Tip:** Bolt uses an internal version of Puppet that supports tasks and plans, so you do not need to install Puppet. If you use Bolt on a machine that has Puppet installed, then Bolt uses its internal version of Puppet and does not conflict with the Puppet version you have installed.

**Note:** Bolt automatically collects data about how you use it. If you want to opt out of providing this data, you can do so. For more information see, [Analytics data collection](bolt_installing.md#)

## Install Bolt on Windows

Use one of the supported Windows installation methods to install Bolt.

### Install Bolt with MSI 

Use the MSI installer package to install Bolt on Windows.

1.  Download the Bolt installer package from [https://downloads.puppet.com/windows/puppet6/puppet-bolt-x64-latest.msi](https://downloads.puppet.com/windows/puppet6/puppet-bolt-x64-latest.msi).
2.  Double-click the MSI file and run the installation.
3.  Run a Bolt command and get started.

    ```
    bolt --help
    ```


### Install Bolt with Chocolatey

Use the package manager Chocolatey to install Bolt on Windows.

You must have the Chocolatey package manager installed.

1.  Download and install the bolt package.

    ```
    choco install puppet-bolt

    ```

2.  Run a Bolt command and get started.

    ```
    bolt --help
    ```

### Add the Bolt module to PowerShell

PowerShell versions 2.0 and 3.0 cannot automatically discover and load the Bolt module, so you'll need to add it manually.

To allow PowerShell to load Bolt, add the module to your PowerShell profile.

1.  Run the following command to update your PowerShell profile:
    ```
    'Import-Module -Name ${Env:ProgramFiles}\WindowsPowerShell\Modules\PuppetBolt' | Out-File -Append $PROFILE
    ```

2.  Re-source your profile to load the module in your current PowerShell window:
    ```
    . $PROFILE
    ```

Bolt will now automatically load every time you open PowerShell.


## Install Bolt on macOS

Use one of the supported macOS installation methods to install Bolt.

### Install Bolt with macOS installer 

Use the Apple Disk Image \(DMG\) to install Bolt on macOS.

1.  Download the Bolt installer package for your macOS version.

    **Tip:** To find the macOS version number on your Mac, go to the Apple \(\) menu in the corner of your screen and choose **About This Mac**.

    -   10.11 \(El Capitan\) [https://downloads.puppet.com/mac/puppet6/10.11/x86\_64/puppet-bolt-latest.dmg](https://downloads.puppet.com/mac/puppet6/10.11/x86_64/puppet-bolt-latest.dmg)
    -   10.12 \(Sierra\) [https://downloads.puppet.com/mac/puppet6/10.12/x86\_64/puppet-bolt-latest.dmg](
    https://downloads.puppet.com/mac/puppet6/10.12/x86_64/puppet-bolt-latest.dmg)
    -   10.13 \(High Sierra\) [https://downloads.puppet.com/mac/puppet6/10.13/x86\_64/puppet-bolt-latest.dmg](https://downloads.puppet.com/mac/puppet6/10.13/x86_64/puppet-bolt-latest.dmg)
    -   10.14 \(Mojave\) [https://downloads.puppet.com/mac/puppet6/10.14/x86\_64/puppet-bolt-latest.dmg](
    https://downloads.puppet.com/mac/puppet6/10.14/x86_64/puppet-bolt-latest.dmg)
2.  Double-click the `puppet-bolt-latest.dmg` file to mount it and then double-click the `puppet-bolt-[version]-installer.pkg` to run the installation.
3.  Run a Bolt command and get started.

    ```
    bolt --help
    ```


### Install Bolt with Homebrew

Use the package manager Homebrew to install Bolt on macOS.

You must have the command line tools for macOS and the Homebrew package manager installed.

1.  Download and install the bolt package.

    ```
    brew cask install puppetlabs/puppet/puppet-bolt

    ```

2.  Run a Bolt command and get started.

    ```
    bolt --help
    ```


## Install Bolt on \*nix

Use one of the supported \*nix installation methods to install Bolt.

**Warning:** These instructions describe enabling the Puppet Tools repository
to install Bolt.  While Bolt can also be installed from the Puppet 6 or 5
Platform repositories adding these repositories to a puppet managed node may
result in an incompatible version of a package like puppet-agent being
installed. That may cause downtime especially on a Puppet Enterprise Master.

### Install Bolt on Debian or Ubuntu

Packaged versions of Bolt are available for Debian 8 and 9 and Ubuntu 14.04, 16.04 and 18.04.

The Puppet Tools repository for the APT package management system is [https://apt.puppet.com](https://apt.puppet.com). Packages are named using the convention `puppet-tools-release-<VERSION CODE NAME>.deb`. For example, the release package for Puppet Tools on Debian 8 “Jessie” is `puppet-tools-release-jessie.deb`.

1.   Download and install the software and its dependencies. Use the commands appropriate to your system.
    -    Debian 8

        ```
        wget https://apt.puppet.com/puppet-tools-release-jessie.deb
        sudo dpkg -i puppet-tools-release-jessie.deb
        sudo apt-get update
        sudo apt-get install puppet-bolt

        ```

    -    Debian 9

        ```
        wget https://apt.puppet.com/puppet-tools-release-stretch.deb
        sudo dpkg -i puppet-tools-release-stretch.deb
        sudo apt-get update
        sudo apt-get install puppet-bolt
        ```


    -    Ubuntu 16.04

        ```
        wget https://apt.puppet.com/puppet-tools-release-xenial.deb
        sudo dpkg -i puppet-tools-release-xenial.deb
        sudo apt-get update
        sudo apt-get install puppet-bolt
        ```

    -    Ubuntu 18.04

        ```
        wget https://apt.puppet.com/puppet-tools-release-bionic.deb
        sudo dpkg -i puppet-tools-release-bionic.deb
        sudo apt-get update
        sudo apt-get install puppet-bolt
        ```

2.  Run a Bolt command and get started.

    ```
    bolt --help
    ```


### Install Bolt on RHEL, SLES, or Fedora

Packaged versions of Bolt are available for Red Hat Enterprise Linux 6 and 7, SUSE Linux Enterprise Server 12, and Fedora 28 and 29.

The Puppet Tools repository for the YUM package management system is [http://yum.puppet.com/puppet-tools/](http://yum.puppet.com/puppet-tools/) Packages are named using the convention `puppet-tools-release-<OS ABBREVIATION>-<OS VERSION>.noarch.rpm`. For example, the release package for Puppet Tools on Linux 7 is `puppet-tools-release-el-7.noarch.rpm`.

1.  Download and install the software and its dependencies. Use the commands appropriate to your system.
    -   Enterprise Linux 6

        ```
        sudo rpm -Uvh https://yum.puppet.com/puppet-tools-release-el-6.noarch.rpm
        sudo yum install puppet-bolt
        ```

    -   Enterprise Linux 7

        ```
        sudo rpm -Uvh https://yum.puppet.com/puppet-tools-release-el-7.noarch.rpm
        sudo yum install puppet-bolt
        ```

    -   Enterprise Linux 8

        ```
        sudo rpm -Uvh https://yum.puppet.com/puppet-tools-release-el-8.noarch.rpm
        sudo yum install puppet-bolt
        ```


    -   SUSE Linux Enterprise Server 12

        ```
        sudo rpm -Uvh https://yum.puppet.com/puppet-tools-release-sles-12.noarch.rpm
        sudo zypper install puppet-bolt
        ```

    -   Fedora 28

        ```
        sudo rpm -Uvh https://yum.puppet.com/puppet-tools-release-fedora-28.noarch.rpm
        sudo dnf install puppet-bolt
        ```

    -   Fedora 29

        ```
        sudo rpm -Uvh https://yum.puppet.com/puppet-tools-release-fedora-29.noarch.rpm
        sudo dnf install puppet-bolt
        ```

    -   Fedora 30

        ```
        sudo rpm -Uvh https://yum.puppet.com/puppet-tools-release-fedora-30.noarch.rpm
        sudo dnf install puppet-bolt
        ```

2.  Run a Bolt command and get started.

    ```
    bolt --help
    ```


## Install gems with Bolt packages

Bolt packages include their own copy of Ruby.

When you install gems for use with Bolt, use the `--user-install` flag to avoid requiring privileged access for installation. This option also enables sharing gem content with Puppet installations — such as when running `apply` on `​localhost` — that use the same Ruby version.​

To install a gem for use with Bolt, use the command appropriate to your operating system: 

-   On Windows with the default install location, `"C:/Program Files/Puppet Labs/Bolt/bin/gem.bat" install --user-install <gem>`
-   On other platforms, `/opt/puppetlabs/bolt/bin/gem install --user-install <gem>`


## Install Bolt as a gem

Starting with Bolt 0.20.0, gem installations no longer include core task modules.

To install Bolt reliably and with all dependencies, use one of the Bolt installation packages instead of a gem.

## Analytics data collection

Bolt collects data about how you use it. You can opt out of providing this data.

### What data does Bolt collect?

- Version of Bolt
- The Bolt command executed \(for example, `bolt task run` or `bolt plan show`\), excluding arguments
- The functions called from a plan, excluding arguments
- User locale
- Operating system and version
- Transports used \(SSH, WinRM, PCP\) and number of targets
- The number of nodes and groups defined in the Bolt inventory file
- The number of nodes targeted with a Bolt command
- The output format selected \(human-readable, JSON\) 
- How the bolt project directory was determined \(ie from the location a `bolt.yaml` file or with the `--boltdir` flag.\)
- The number of times Bolt tasks and plans are run \(This does not include user-defined tasks or plans.\)
- Number of statements in an apply block, and how many resources that produces for each target.
- Number of steps in a YAML plan
- Return type (expression vs. value) of a YAML plan
- Which bundled Bolt plugins are used \(This does not include user-installed plugins.\)

This data is associated with a random, non-identifiable user UUID.

To see the data Bolt collects, add `--debug` to a command.

### Why does Bolt collect data?

Bolt collects data to help us understand how it's being used and make decisions about how to improve it.

### How can I opt out of Bolt data collection?

To disable the collection of analytics data add the following line to `~/.puppetlabs/bolt/analytics.yaml` on Unix systems or ` %USERPROFILE%\.puppetlabs\bolt\analytics.yaml` on Windows:

```
disabled: true
```

