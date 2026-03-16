Introduction:
This is lab 1 for ECE383. In this lab the goal was to create the code to have a vga signal be printed to a screen using our Artix-7 FPGA 
board. 

Design/ Implementation:
The design included one top level component named Lab 1. Inside this top level design was 3 components. 2 numerical counters, which could 
count up and count down from a minimum value to a maximum value. In addition they allowed for the step (delta) to be more than 1.
Furthermore, the count would not exceed the maximum value or go below the minimum value, and instead will just stay at that value if 
attempting to move past it. The third component is the video component, which was created for me. It contains the clock wiz component
which is pre created by the company who created my FPGA, and was simply needed to be initliazed in certain ways. The other component 
is the VGA, which includes the VGA signal generator and the color mapper, both written by me. What the signal generator does is allows
me to create certain signals for the vga based on inputted constraints. The color mapper allows me to control what color is outputted to
the screen based on my location on the screen, which allows me to create the gridlines and triggers and hashes and channel lines. 
Updated block diagram:
![alt text]https://usafa0-my.sharepoint.com/:b:/g/personal/c28asher_speicher_afacademy_af_edu/IQDbh9SksPv6RLfRwvO9BLWJAboYyRc3PBV9IanIE_SFdP0?email=james.trimble%40afacademy.af.edu&e=MiCtFC
Initial diagram design:
![alt text]https://usafa0-my.sharepoint.com/:b:/g/personal/c28asher_speicher_afacademy_af_edu/IQC3_1p7-RNqQrWnJwm7uWkAAR7XgXlv2h5yXBx92WbBz8w?email=james.trimble%40afacademy.af.edu&e=lgvcJM

Test/ Debug:
The main method used to verify system functionality was the test benches. However, with Col Trimble's guidance I also started using 
break points as well as creating signals so I could specifically see certain expressions to see if they would be true or false.
I certainly learned that debugging is one of the most vital skills I will need for this course and computer engineering. 

hysync going high low and high in relation to col count
![alt text]https://usafa0-my.sharepoint.com/:i:/g/personal/c28asher_speicher_afacademy_af_edu/IQDhudMBmt-KQKtRkblrymxUAfyQNWhkl4IfBFSHk4iPSu0?email=james.trimble%40afacademy.af.edu&e=3VX94D
![alt text]https://usafa0-my.sharepoint.com/:i:/g/personal/c28asher_speicher_afacademy_af_edu/IQCZ3h9Lx8BjRZFJ_I_YfxvpAbgHE0FCAKNfVxxvCJKkn8E?email=james.trimble%40afacademy.af.edu&e=mEuTNI
vsync going high low and high in relation to row and col count 
![alt text]https://usafa0-my.sharepoint.com/:i:/g/personal/c28asher_speicher_afacademy_af_edu/IQCRmpI0A4KrQbF6FXPM2HmiAeS4wTT1nLOlWPOi76q0jHs?email=james.trimble%40afacademy.af.edu&e=68Ukq2
![alt text]https://usafa0-my.sharepoint.com/:i:/g/personal/c28asher_speicher_afacademy_af_edu/IQAJeucBh_4NQ6ywC14uv6c4AdMPgu165r4i_abDE8rAgLQ?email=james.trimble%40afacademy.af.edu&e=P7KY8Y
blank signal going high low high in relation to row and col count
![alt text]https://usafa0-my.sharepoint.com/:i:/g/personal/c28asher_speicher_afacademy_af_edu/IQCbAClGW11EQJRLz2GCoEz5AZ_goFsN6xqJAbPoHRb0UNw?email=james.trimble%40afacademy.af.edu&e=wDKZ5M
![alt text]https://usafa0-my.sharepoint.com/:i:/g/personal/c28asher_speicher_afacademy_af_edu/IQAowhUwhGRIRrB1t23n06C-AZyv_k2oVw0-0XAt3gl2YY8?email=james.trimble%40afacademy.af.edu&e=bYp54b
col count rolling over and max vals for each counter
![alt text]https://usafa0-my.sharepoint.com/:i:/g/personal/c28asher_speicher_afacademy_af_edu/IQCQCqgEoKOhSbcrQe4rrn0bAW4Ot7v-xbL_51sILKFMxZc?email=james.trimble%40afacademy.af.edu&e=fSloEY

I ran into two primary issues

The first issue I ran into was when I was trying to print my board and I was getting the screen to just be all one color. Col Trimble
worked with me to find a number of solutions, including looking at the raw data for .txt file, setting different colors to see if it 
was a color issue, or others things. Finally, the issue was solved when Mohammed looked at the code for about two seconds and noticed
that I did not have the else false statements on my colors, so since channel 1 was my top left corner, everything became yellow 
because channel 1 active was always true and caused the entire screen to be yellow.

The second issue I ran into was trying to figure out why I had way too many boxes and gridlines. The reason behind this was the fact 
that I had only checked if the gridlines existed within a certain column, and not a certain column within the center line for either
major axis. To debug this I had a conversation with Col Trimble who led me to the answer without giving it to me, including changing 
the color of the gridlines to show me that the hash marks were the ones causing the issue. To solve this issue I went and 
changed the the gridlines to only exist within a certain distance of the major axis, which worked well.

Results:
The results from this lab were great! I was not initally locked in on this class due to some personal issues, but I was able to 
complete each gate check before it was due and turn them in. Unfortunently, not full points were achieved because I did not follow the
proper instructions of what to upload, which is on me. However, the work was completed before each gate check. Additionally, the work was 
completed for this assignment, with lots of debugging help from Col Trimble, but in the end of the day I truly understood the assignment
and am happy I was able to complete it. 


Conclusion:
I learned from this lab mostly the difficulty and level of work that are going to be required for this class. I think in future years 
I would not really change much. I think there was a fair amount of code given but also a fair amount of ambiguity left in there to make
sure that I could figure out how to do things myself, which was nice and helpful. Fun lab!
