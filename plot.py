import json
import matplotlib.pyplot as plt

f = open('results/1G/single_run/bbr/out1.json')
data1 = json.load(f)
f.close()
f = open('results//1G/single_run/bbr/out2.json')
data2 = json.load(f)
f.close()

duration = data1["start"]["test_start"]["duration"]
t = range(0,duration)

th1 = []
th2 = []
th1 = [0 for i in range(duration)] 
th2 = [0 for i in range(duration)] 
fairness = [0 for i in range(duration)] 


for j in range(0,duration):
    th1[j] += data1["intervals"][j]["sum"]["bits_per_second"]/(1e9)
    th2[j] += data2["intervals"][j]["sum"]["bits_per_second"]/(1e9)
    fairness[j] = 100*(th1[j] + th2[j])**2 / (2 * (th1[j]**2 + th2[j]**2))
    
#print(fairness)    
#Plt and subplts definition
fig, plt = plt.subplots(2, 1, sharex=True,figsize=(7,7))
fig.subplots_adjust(hspace=0.1)

#Plot grids
plt[0].grid(True, which="both", lw=0.3, linestyle=(0,(1,10)), color='black')
plt[1].grid(True, which="both", lw=0.3, linestyle=(0,(1,10)), color='black')

#Colors
#Gold: #E5B245
#Blue: #2D72B7 
#Green: #82AA45
#Garnet: #95253B

#Plotting the metrics as a time's function
plt[0].plot(t, fairness,'#E5B245', linewidth=2, label='Fairness')
plt[1].plot(t, th1,'#2D72B7', linewidth=2, label='< 0.1ms')
plt[1].plot(t, th2,'#95253B', linewidth=2, label='60ms')
   
#Setting the y-axis labels and the x-axis label
plt[0].set_ylabel('Fairness [%]', fontsize=14)
plt[1].set_ylabel('Throughput [Gbps]', fontsize=14)
plt[1].set_xlabel('Time [s]', fontsize=14)

#Plot legends
plt[0].legend(loc="upper right")
plt[1].legend(loc="upper right", ncol=2)

#Setting the position of the y-axis labels
plt[0].yaxis.set_label_coords(-0.1,0.5)
plt[1].yaxis.set_label_coords(-0.1,0.5)

#Setting the x-axis labels font size
plt[0].tick_params(axis='y', labelsize=14 )
plt[1].tick_params(axis='y', labelsize=14 )
plt[1].tick_params(axis='x', labelsize=14 )

#Setting the y-axis limits
plt[0].set_ylim([0,100])#fairness
plt[1].set_ylim([0,1.2])#throughput

fig.savefig("test_plot.png", bbox_inches='tight')
