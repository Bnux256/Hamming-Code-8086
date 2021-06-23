# (11,15) Hamming Code - 8086 Processor
## Calculating and fixing 15 bit Hamming Code + SECDED 16 bit Hamming Code with an extra parity bit. 
### Background Information
<img align="right" width="180" height="240" src = "https://user-images.githubusercontent.com/80382873/121411089-ee33fc00-c96b-11eb-9e89-25ae1cc62645.jpg">
Richard Hamming, the inventor of Hamminging codes, worked at Bell Lab in the 1940s. On the weekends, Hamming brought to the company's computer code on punch cards. Because the card readers from the period were unreliable, and sometimes the cards themselves also had errors, when he returned on Monday after the weekend, he saw that the computer exited out of the program because of the errors. Hammning was so upset by this ongoing problem that in the following years he invented several algorithms to correct errors.

In the first algorithm he invented, he wrote each bit three times, so if one of the three was incorrect, the error can be corrected, since there were two more correct bits. The great advantage of this method is that it is very easy to apply. However, ⅔ from the data is used for the redundancy, which made the algorithm inefficient.

Finally, he invented an algorithm that uses parity bits located in numbers that their index is a power of 2. They indicate whether the number of times the digit 1 
<img align="right" width="175" height="162" src = "https://user-images.githubusercontent.com/80382873/121413739-abbfee80-c96e-11eb-87b0-f02618ec2a0f.png">
appears is even or odd. Each bit in the given codeword is covered by at least 2 parity bits. 
Therefore, it is possible to verify which relationship bits are incorrect, their amount will indicate the position of the incorrect bit. With the help of the relationship bits it is possible to identify if there is an error, and to correct it.

## Example - 
Bit Number | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15
-----------|---|---|---|---|---|---|---|---|---|----|----|----|----|----|----
Original Msg. | P1 | P2 | 0 | P4 | 1 | 1 | 0 | P4 | 1 | 0 | 0 | 1 | 1 | 0 | 0
Parity Bits Of: | 1,3,5,7,9,11,13,15 | 2,3,6,7,10,11,14,15 | | 4,5,6,7,12,14,15 | | | | 8,9,10,11,12,14,15 | | | | | | |
Encoded Data: | 1 | 1 | 0 | 0 | 1 | 1 | 0 | 1 | 1 | 0 | 0 | 1 | 1 | 0 | 0 |

## User Guide
When running the program you will be prompted to choose between 2 options: 
* The first will allow the user to enter data that is 11 bits and the program will return its 15 bit Hamming Code, with four added parity bits. 
* The other option allows the user to enter a 15 bit Hamming Code, and it will print if there was any error in the data and return the corrected Hamming Code.
* The user can also choose to generate or correct a SECDED Hamming Code with an extra parity bit.
<img align="center" src = "https://user-images.githubusercontent.com/80382873/121419679-e3319980-c974-11eb-8607-40599763e426.png">
## SECDED Hamming Code
Normally, Hamming Codes can only correct a single error in the codeword, as it can’t distinguish a double error from a single bit error of a different codeword. If the codeword is 111111111111111, and the delivered message is 1101011111111111, the algorithm will return that bit 6 is wrong, instead of bits 3 and 5. Adding an additional parity bit that covers the entire codeword will make it possible to know whether there is a double-bit error.
#### There are four possible cases:
* All bits are correct + extra parity correct --> no errors
* All bits are correct + extra parity not correct --> extra parity bit is wrong
* Some bit is wrong + extra bit is no correct --> fixable 1 bit error
* Some bit is wrong + extra bit is correct --> unfixable double bit error

## Flow Chart - 
<img align="center" src = "https://github.com/Bnux256/HammingCode-11-15--8086/blob/main/ProjectDiagram.png?raw=true">

## Reference Material
* [Hamming Code, Wikipedia.](https://en.wikipedia.org/wiki/Hamming_code)
* [Calculating and Correcting Hamming Codes. (1999). Florida International Univercity.](http://users.cs.fiu.edu/~downeyt/cop3402/hamming.html)
* [Chapter 5: Memory & Hamming/SECDED Codes, Intro to Computer Systems. (2014). RMIT Univercity.](https://www.dlsweb.rmit.edu.au/set/Courses/Content/CSIT/oua/cpt160/2014sp4/chapter/05/CodingSchemes.html)
* [Error Detecting and Error Correcting Codes. (1950). Richard Hamming, Bell Lab's Journal.](http://guest.engelschall.com/~sb/hamming/)
* [Hamming codes and error correction, (2020). 3Blue1Brown Youtube chanel.](https://www.youtube.com/watch?v=X8jsijhllIA&)
