# Known issues

Known issues for the Bolt 1.x release series.

## False errors for SSH Keys generated with ssh-keygen OpenSSH 7.8 and later

The OpenSSH 7.8 release introduced a change to SSH key generation. It now generates private keys with its own format rather than the OpenSSL PEM format. Because the Bolt SSH implementation assumes any key that uses the OpenSSH format uses the public-key signature system ed25519, false errors have resulted. For example:

```
OpenSSH keys only supported if ED25519 is available
  net-ssh requires the following gems for ed25519 support:
   * ed25519 (>= 1.2, < 2.0)
   * bcrypt_pbkdf (>= 1.0, < 2.0)
  See https://github.com/net-ssh/net-ssh/issues/565 for more information
  Gem::LoadError : "ed25519 is not part of the bundle. Add it to your Gemfile."
```

or

```
Failed to connect to HOST: expected 64-byte String, got NUM 
```

Workaround: Generate new keys with the ssh-keygen flag `-m PEM`. For existing keys, OpenSSH provides the export \(`-e`\) option for exporting from its own format, but export is not implemented for all private key types. [\(BOLT-920\)](https://tickets.puppet.com/browse/BOLT-920) 

## JSON strings as command arguments may require additional escaping in PowerShell

When passing complex arguments to tasks with `--params`, Bolt may require a JSON string (typically created with the `ConvertTo-Json` cmdlet) to have additional escaping. In some cases, the PowerShell stop parsing symbol `--%` may be used as a workaround, until Bolt provides better PowerShell support [\(BOLT-1130\)](https://tickets.puppet.com/browse/BOLT-1130)

## Limited Kerberos support

While we would like to support Kerberos over SSH for authentication, a license incompatibility with other components we are distributing means that we cannot recommend using the net-ssh-krb gem for this functionality. [\(BOLT-980\)](https://tickets.puppet.com/browse/BOLT-980)

Support for Kerberos over WinRM from a Linux host is currently experimental and requires the [MIT kerberos library be installed](https://web.mit.edu/Kerberos/www/krb5-latest/doc/admin/install_clients.html). Support from Windows [\(BOLT-1323\)](https://tickets.puppet.com/browse/BOLT-1323) and OSX [\(BOLT-1471\)](https://tickets.puppet.com/browse/BOLT-1471) will be implemented in the future.

## Tasks executed with Powershell 2

When executing powershell tasks on targets using a powershell interpreter version 2 or earlier, the task parameter with the name `type` cannot be used. Bolt versions 1.30.0 and earlier contained [a bug](https://github.com/puppetlabs/bolt/issues/1205) where parameters that contain the string `type` in the name (for example `serverType`) were incompatible. With bolt versions 1.31.0 and greater only powershell parameters with the name `type` cannot be used. Note that for newer versions of powershell this is not an issue.
