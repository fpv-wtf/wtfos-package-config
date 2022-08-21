# wtfos-package-config

This repository implements the CLI tool `package-config` to interact with individual wtfos package's configuration options manually.

## Usage
```
Usage: package-config <subcommand> [options]

Subcommands:
    get <package>                  show all keys for package
    get <package> <key>            get value for key in package
    set <package> <key> <value>    set value for key in package
    reset <package>                forget unapplied changes
    apply <package>                restart the package dinit unit if it exists    
```

### Show a current setting value
```
package-config get msp-osd debug
```

### Update settings values
```
package-config set msp-osd somebool true
package-config set msp-osd someint 4
package-config set msp-osd somestring "hello i am string"

package-config apply msp-osd
```
In order to avoid restarting services with partially incomplete configuration sets and too often, you must use `package-config apply $PACKAGE_NAME` command to finalize any settings and actually write to the packages configuration file. This works much like Betaflight's save command, except on a per-package basis and pending values only get reset on a power cycle or when you run `package-config reset $PACKAGE_NAME`.

### Show all settings for package
```
package-config get msp-osd
```

## For package authors
Your package should depend on `wtfos-package-config`.

Install your [schema.json](./testschema.json) and default [config.json](./testconfig.json) into `/opt/etc/package-config/$PACKAGE_NAME/`.

Check out the linked files above for examples, supported types and constraints. In order for a field to be settable it *must* be defined with a certain type in your schema.json. All constaints are optional and will be ignored if not persent.

For more details see [this wtfos-configurator issue](https://github.com/fpv-wtf/wtfos-configurator/issues/7).

## Development and testing

Any new features added need to get a an appropraite test added to `test.sh`. The test set should always be ran sucsessfully before publishing any version.

To generate packages run:
```
make ipk
```