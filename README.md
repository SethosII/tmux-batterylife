tmux-batterylife
================

Show battery life as hearts in tmux

<table border="0">
	<tr>
		<td>red hearts</td><td>charged</td>
	</tr<
	<tr>
		<td>white hearts</td><td>not charged</td>
	
	<tr>
		<td>black hearts</td><td>gap between designed charge and last maximum charge</td>
	</tr>
</table>

how to use:
<ul>
	<li>add a line in your ~/.tmux.conf to change the status bar - an example is given in the example_tmux.conf file</li>
	<li>copy the tmux_battery_charge_indicator.sh file to the directory specified in your ~/.tmux.conf</li>
</ul>

inspired by http://ficate.com/blog/2012/10/15/battery-life-in-the-land-of-tmux/
