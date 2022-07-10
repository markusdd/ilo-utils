# Honorable Mentions

The whole idea stems from this Github Gist (https://gist.github.com/kiler129/904fe463b008e740315c4abaf33c68af#file-ilo-console-sh).

I used it as a starting point to modify the ilo-console.sh script (it needed quite some tweaking) and derive the ilo-proxy.sh script.
It did not work out of the box on newer systems due to additional opnessl config needed by curl. Also the required Java setup is automated now and
based on your server farm helper scripts get generated so you basically have a single command solution for all of your machines.
But I think it is wise to keep the reference to the original file around to see where it all started from. Thanks kiler129.

Also I wish to thank the guys from mitmproxy for their excellent tool. Give them some love as well!
