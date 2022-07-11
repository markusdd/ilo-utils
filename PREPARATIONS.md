# PREPARATIONS

Make sure you have done/checked the things below, otherwise you might experience issues.

- set all ilo3 interfaces to enforce AES/DES encrpytion, not needed for ilo4/5 (they speak TLSv1.2)
  - see bottom of README.md about how to do this via CLI if you cannot get to the webpage at all anymore
  - this is required to make any reasonable OpenSSL version work at all, FIPS mode has NOT been tested
- make sure your iLO interface firmwares are up to date and especially the same (iLO 3 should be at 1.94, iLO 4 min. at 2.79, iLO 5 min. at 2.63)
  - the name of the jar file to be downloaded for the console can change as the iLO version increases, so if you get a "cannot load resource" error, you might have to adapt it in ilo-console.sh
  - to know the name, you must download the .jnlp file from the webpage of the affected iLO and check the link within (you get it by clicking the Java webstart button in the Remote Console menu)
- make sure your iLO machines have one common account name you use for login (e.g. Administrator)
- this has all been tested on RedHat family distros (most stuff on Fedora 36, the iLO 3 proxy service on RockyLinux 8), your mileage may vary on others and require adaptations
  - if you plan to use the proxy service file, be mindful my implementation contains firewall-cmd settings, you might have to change this to fit your firewall
  - the place for the adaptation is the `generate-ilo-scripts.sh`
- look over the scripts provided here before you execute them, you might see things you wish to adapt to your situation
- you MUST stick to the Java 8 version downloaded by the base-install.sh script, OpenJDK webstart does NOT work, we unfortunately need original Java
- base-install.sh will download an older version (6.0.2) of mitmproxy ON PURPOSE, this is because of cipher support in their packaged OpenSSL
- I assume linux x86_64 for everything I download
- make sure you have libnsl installed on your system (required by Java webstart)

