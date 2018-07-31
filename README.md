## TCA9539 I2C GPIO Expander Setup in Linux for Jetson TX2

### Introduction
Instead of sourcing GPIO's directly from the Nvidia Jetson TX2, the ConnectTech Spacely Carrier uses an onboard I2C GPIO expander to create external GPIO's. Because a GPIO Expander is utilized, we will have to access the I2C bus and consequently access the GPIO Expander's specific I2C address. Another downfall of this is that EVERY time the Spacely is power-cycled, the GPIO's will be reset to their default values and MUST be reconfigured in the initialization script during startup.

By default, the GPIO's are all set to inputs at 3.3V logic high and will be reset to their default states after a power-cycle. Thus, a script must be made to initialize the GPIO ports as inputs and outputs specific to our application (aka the PCB) on power-up. Most of the GPIO's are also set to a "sleep" state and they must be exported in order to be used. This readme covers a tutorial on using the bash script I have written to initialize the GPIO's or manually initializing the GPIO's. Unless you are STU or some other software nerd, I reccommend first going through the manual initialization as it will aid in understanding.

### Bash Script TCA9539 GPIO Initialization
Download the "GPIOInit.sh" bash script from this repository. Move the script to your working bin directory. Make sure that you make the bash script executable by running the following command:

> chmod u+x GPIOInit.sh

Before executing the script, enter root by the command:

> sudo bash

Execute the GPIO Initialization script with the following command:

> bash GPIOInit.sh

You should now see that the appropriate GPIO's have been initialized and are configured to the correct state. GPIO Configuration is now complete - if you would like to change the state of the GPIO's however, you must manually assert their states in a terminal or in another program such as cpp.


### Manually Initializing the TCA9539 and Exporting GPIO's
First, one must enter root in an open terminal as the I2C commands will require specific permissions. Sudo will not work as the '>' in commands will break the sudo permissions. To enter root, run the following command:

> sudo bash

Next, ensure that the TCA9539 chip can be seen by the Jetson TX2's kernel by typing the command:

> cat /sys/kernel/debug/gpio

A list should appear that looks similar or exactly the same as:

> GPIOs 216-231, i2c/0-0077, tca9539, can sleep:
>
> GPIOs 232-247, i2c/0-0074, tca9539, can sleep:
>  gpio-233 (                    |cam_c_rst           ) out lo    
>  gpio-235 (                    |cam_d_rst           ) out lo    
>  gpio-237 (                    |cam_e_rst           ) out lo    
>  gpio-239 (                    |cam_f_rst           ) out lo    
>
> GPIOs 248-255, platform/max77620-gpio, max77620-gpio, can sleep:
>  gpio-248 (                    |external-connection:) in  lo    
>  gpio-253 (                    |spmic_gpio_input_5  ) in  lo    
>  gpio-254 (                    |spmic_gpio_input_6  ) in  hi    
>
> GPIOs 256-319, platform/c2f0000.gpio, tegra-gpio-aon:
>  gpio-272 (                    |temp_alert          ) in  hi    
>  gpio-312 (                    |Power               ) in  hi    
>  gpio-313 (                    |Volume Up           ) in  hi    
>  gpio-314 (                    |Volume Down         ) in  hi    
>  gpio-315 (                    |wifi-wake-ap        ) in  lo    
>  gpio-316 (                    |bt_host_wake        ) in  lo    
>
> GPIOs 320-511, platform/2200000.gpio, tegra-gpio:
>  gpio-381 (                    |reset_gpio          ) out lo    
>  gpio-412 (                    |vdd-usb0-5v         ) in  hi    
>  gpio-413 (                    |vdd-usb1-5v         ) in  hi    
>  gpio-420 (                    |eqos_phy_reset      ) out hi    
>  gpio-421 (                    |eqos_phy_intr       ) in  hi    
>  gpio-424 (                    |wlan_pwr            ) out hi    
>  gpio-426 (                    |cam1-pwdn           ) out lo    
>  gpio-441 (                    |hdmi2.0_hpd         ) in  lo    
>  gpio-444 (                    |wp                  ) in  lo    
>  gpio-445 (                    |cd                  ) in  lo    
>  gpio-446 (                    |en-vdd-sd           ) out hi    
>  gpio-456 (                    |cam0-pwdn           ) out lo    
>  gpio-457 (                    |cam1-rst            ) out lo    
>  gpio-459 (                    |pcie-lane2-mux      ) out lo    
>  gpio-461 (                    |cam0-rst            ) out lo    
>  gpio-479 (                    |external-connection:) in  hi    
>  gpio-484 (                    |bt_ext_wake         ) out hi 

Notice that the GPIO's associated with the TCA9539 are labeled 216-239. These are the GPIO's of interest, and the exact pin-numbers of the GPIO's on the Spacely GPIO header are found in http://connecttech.com/resource-center/kdb342-using-gpio-connect-tech-jetson-tx1-carriers/.

Specific to the 'Spork' PCB, the following table lists what GPIO's we use and what their associated values must be:

|Header-Pin#|    sysfs#|     Input/Output|     Schematic Reference|     Description of Functionality|
|-----------|----------|-----------------|------------------------|---------------------------------|
|J1-1       |    230   |     Output      |     CHGEN              |  Enables Battery Charging when Logic HIGH|
|J1-3|           228   |     Input       |     !ACP               |  Flag - Indicates when AC adapter is present when Logic LOW|
|J1-5       |    226   |    Input        |     !SMBALERT          |  Flag - Indicates a problem present with the battery|
|J1-7       |    224   |    Output       |   KILL_SIG_DELAY       |  Disables ALL Power when Logic HIGH after 1s Delay|
|J1-9       |    222   |    Output       |   KILL_SIG             |  Disables ALL Power when Logic HIGH immediately|
|J1-13      |    218   |    Output       |   SCREEN_KILL            |  Enables the Screen Power when Logic HIGH|
|J1-15      |    216   |    Input        |   SCREEN_STATUS        |  Flag - Indicates when the Screen is Enabled if Logic HIGH|
|J1-2       |    231   |     Input       |   LIDAR_STATUS         |  Flag - Indicates when the Lidar is Enabled if Logic HIGH|
|J1-4       |    229   |     Output      |   LIDAR_EN             |  Enables the Lidar Power when Logic HIGH|
|J1-6       |    227   |     Input       |   !CAMERA_INT          |  Flag - Indicates a User Request for Camera Interrupt|

We need to export all of these GPIO's but first, we initialize the TCA9539 GPIO expander by writing to it's I2C Address 0x77 with the following command:

> echo tca9539 0x77 > /sys/bus/i2c/devices/i2c-1/new_device

To export the GPIO's, execute the following commands:

> echo 216 > /sys/class/gpio/export
>
> echo 218 > /sys/class/gpio/export
>
> echo 222 > /sys/class/gpio/export
>
> echo 224 > /sys/class/gpio/export
>
> echo 226 > /sys/class/gpio/export
>
> echo 228 > /sys/class/gpio/export
>
> echo 230 > /sys/class/gpio/export
>
> echo 229 > /sys/class/gpio/export
>
> echo 227 > /sys/class/gpio/export
>

Ensure that you have correctly exported the desired GPIO's by running another check on the TX2's I2C Kernel with the command:

> cat /sys/kernel/debug/gpio

This time the table that should appear in the terminal should be exactly the same as the following which now shows the 

> GPIOs 216-231, i2c/0-0077, tca9539, can sleep:
>  gpio-216 (                    |sysfs               ) in  lo    
>  gpio-218 (                    |sysfs               ) in  lo    
>  gpio-222 (                    |sysfs               ) in  lo    
>  gpio-224 (                    |sysfs               ) in  lo    
>  gpio-226 (                    |sysfs               ) in  lo    
>  gpio-227 (                    |sysfs               ) in  lo    
>  gpio-228 (                    |sysfs               ) in  lo    
>  gpio-229 (                    |sysfs               ) in  lo    
>  gpio-230 (                    |sysfs               ) in  lo    
>
> GPIOs 232-247, i2c/0-0074, tca9539, can sleep:
>  gpio-233 (                    |cam_c_rst           ) out lo    
>  gpio-235 (                    |cam_d_rst           ) out lo    
>  gpio-237 (                    |cam_e_rst           ) out lo    
>  gpio-239 (                    |cam_f_rst           ) out lo 

Finally we need to set the appropriate GPIO's to output's as well as change the desired default state for the input GPIO's. First, we will execute the commands to set our GPIO's as outputs:

> echo out > /sys/class/gpio/gpio218/direction
> echo out > /sys/class/gpio/gpio222/direction
> echo out > /sys/class/gpio/gpio224/direction
> echo out > /sys/class/gpio/gpio230/direction
> echo out > /sys/class/gpio/gpio229/direction

For learning purposes, you should run the i2c kernel list command again to view that the respective GPIO's are now configured as active low outputs. When active low, the pins will read 1 when the state of the pin is at 0.

To read the current value of the GPIO, use the command:

> cat /sys/class/gpio/gpio#/value
> Where, gpio# is the GPIO sysfs # you wish to access in the form <gpio<sysfs#>>

If the GPIO is configured as an output, then the following command may be used to write a 1 to that GPIO:

> echo 1 > /sys/class/gpio/gpio#/value

For example, the following command will set GPIO 230 or enable charging via CHGEN with the following command:

> echo 1 > /sys/class/gpio/gpio230/value










