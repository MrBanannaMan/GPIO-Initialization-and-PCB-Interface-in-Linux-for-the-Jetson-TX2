## TCA9539 I2C GPIO Expander Setup in Linux for Jetson TX2

### Introduction
Instead of sourcing GPIO's directly from the Nvidia Jetson TX2, the ConnectTech Spacely Carrier uses an onboard I2C GPIO expander to create external GPIO's. Because a GPIO Expander is utilized, we will have to access the I2C bus and consequently access the GPIO Expander's specific I2C address.

By default, the GPIO's are all set to inputs at 3.3V logic high and will be reset to their default states after a power-cycle. Thus, a script must be made to initialize the GPIO ports as inputs and outputs specific to our application (aka the PCB) on power-up. Most of the GPIO's are also set to a "sleep" state and they must be exported in order to be used.

### Initializing the TCA9539 and Exporting GPIO's
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
|J1-13      |    218   |    Output       |   SCREEN_EN            |  Enables the Screen Power when Logic HIGH|
|J1-15      |    216   |    Input        |   SCREEN_STATUS        |  Flag - Indicates when the Screen is Enabled if Logic HIGH|
|J1-2       |    231   |     Input       |   LIDAR_STATUS         |  Flag - Indicates when the Lidar is Enabled if Logic HIGH|
|J1-4       |    229   |     Output      |   LIDAR_EN             |  Enables the Lidar Power when Logic HIGH|
|J1-6       |    227   |     Input       |   !CAMERA_INT          |  Flag - Indicates a User Request for Camera Interrupt|

We need to export all of these GPIO's but first, we initialize the TCA9539 GPIO expander by writing to it's I2C Address 0x77 with the following command:

> echo tca9539 0x77 > /sys/bus/i2c/devices/i2c-1/new_device

To export the GPIO's, execute the following commands:

> echo 216 > /sys/class/gpio/export
> echo 218 > /sys/class/gpio/export
> echo 222 > /sys/class/gpio/export
> echo 224 > /sys/class/gpio/export
> echo 226 > /sys/class/gpio/export
> echo 228 > /sys/class/gpio/export
> echo 230 > /sys/class/gpio/export
> echo 229 > /sys/class/gpio/export
> echo 227 > /sys/class/gpio/export




