figure

plot(time_vector/3600, 100*battery_cap/(200*3600))
title('Battery State-of-Charge vs Time')

hold on

xlim([0, tv_length/(60^2)])

ylim([0,100]);
xlabel('Time (hrs)')
ylabel('State of Charge (100% Max)')



figure 

plot(time_vector/3600, power_gen_timeline)
xlim([0, tv_length/(60^2)])

ylim([0,100]);
xlabel('Time (hrs)')
ylabel('Power Generation (Watts)')


figure 

plot(time_vector/3600, power_con_timeline)
xlim([0, tv_length/(60^2)])

ylim([0,100]);
xlabel('Time (hrs)')
ylabel('Power Consumption (Watts)')

