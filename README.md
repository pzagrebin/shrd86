# shrd86
This is depacker for data compressed with Shrinkler by Aske Simon Christensen:
https://github.com/askeksa/Shrinkler

You can freely use it as you like.

Uses only 8086 instructions, suitable for IBM PC/XT (~2 KB/s on 4.77 MHz 8088).
Assembled size is 177 bytes.

Some speed was sacrificed for size, but not much.
Probably I'll do 286 version too as it can be a bit smaller (and faster) by using 286 commands.
On 386+ it's not useful (at least in real mode form) as you can use more efficient compressors.
