# ServoKnob

This project turns a servo and fades an LED when you turn a potentiometer knob.  
It also turns a second servo from 0-180 degrees and back when you press a button. 
It will also display the LED power and servo angle controlled by the
potentiometer on an RGBLCD display.

On the GrovePi+ GrovePi Zero, connect a potentiometer to port A2, a LED to port 
D3, a PivotPi to I2C-1, a RGBLCD display to I2C-2 (GrovPi+ only), and a button 
to A0. On the PivotPi, plug servos into channels 1 and 2.

If you're on Raspbian (and have the `grovepi` app in your workspace folder), try 
this out by running:

```shell
mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=prod iex -S mix
```
