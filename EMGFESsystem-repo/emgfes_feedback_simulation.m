% A script to test the Active FES feedback routine.
%
aFES=emgfes_feedback(aFES,[0,0,0],0);
sim_Fs=0.001;
for xx=1:10000
    aFES=emgfes_feedback(aFES,[0,0,0,round(rand(1,2)*100)],1);
    pause(sim_Fs)
end
clear sim_Fs xx