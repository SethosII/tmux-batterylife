tmux-batterylife
================

Show battery life as hearts in tmux

![Screenshot](/example.png)

<table border="0">
	<tr>
		<td>red hearts</td><td>charged</td>
	</tr>
	<tr>
		<td>white hearts</td><td>not charged</td>
	<tr>
		<td>black hearts</td><td>gap between designed charge and last maximum charge</td>
	</tr>
</table>

Usage
-----

* Add a line in your ~/.tmux.conf to change the status bar - an example is given in the [example_tmux.conf](/example_tmux.conf) file
* Copy the tmux_battery_charge_indicator.sh file to the directory specified in your ~/.tmux.conf and make it executable

<br/>

Works on Linux and OS X

Inspired by https://aaronlasseigne.com/2012/10/15/battery-life-in-the-land-of-tmux/
