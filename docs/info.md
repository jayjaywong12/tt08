<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Words are 4 bits wide.
Write the length of the 4-bit vectors you want to multiply into address 0.
The vectors should be in words 1-32. Word 1 will be multiplied by word 17, etc.
The result will be accumulated into words 33-34 (8 bits).

## How to test

Use it to multiply vectors I guess.

## External hardware

Will be programmed by RP2040. No other external hardware.
