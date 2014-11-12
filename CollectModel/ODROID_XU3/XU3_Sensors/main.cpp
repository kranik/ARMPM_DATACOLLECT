// Krastin Nikov 2014

#include "getnode.h"
#include <iostream> // cout, endl
#include <cstdlib>	// atoi
#include <csignal>
#include <unistd.h>	// sleep
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <fstream>
#include <time.h>


using namespace std;

GetNode* getNode;

void ctrl_c_handler(int s) {
	getNode->CloseINA231();
	exit(1);
}

int main(int argc, char* argv[])
{
	int numLITTLEcores;
	int numbigcores;

	if (argc > 1) {
		if ((numLITTLEcores = atoi(argv[1])) == 0) {
			cerr << "Argument 1 must be enabled LITTLE cores" << endl;
			exit(1);
		}
	
		if ((numbigcores = atoi(argv[2])) == 0) {
			cerr << "Argument 2 must be enabled big cores" << endl;
			exit(1);
		}
		
	}

	struct sigaction sigIntHandler;
	sigIntHandler.sa_handler = ctrl_c_handler;
	sigemptyset(&sigIntHandler.sa_mask);
	sigIntHandler.sa_flags = 0;
	sigaction(SIGINT, &sigIntHandler, NULL);
	int i;
	time_t t;
    	
	string a15Volt, a15Ampere, a15Watt;
    	string a7Volt, a7Ampere, a7Watt;
    	string gpuVolt, gpuAmpere, gpuWatt;
    	string memVolt, memAmpere, memWatt;

	getNode = new GetNode();

	//Format the header line of the output
	cout << "#Timestamp\t";
	for (i = 0; i < numLITTLEcores; i++)
		cout << "CPU(" << 0+i << ") Frequency(MHz)" << '\t' << "CPU(" << 0+i << ") Temperature(C)" << '\t';
	cout << "A7 Voltage(V)\tA7 Current(A)\tA7 Power(W)\t";

        for (i = 0; i < numbigcores; i++)
                cout << "CPU(" << 4+i << ") Frequency(MHz)" << '\t' << "CPU(" << 4+i << ") Temperature(C)" << '\t';
        cout << "A15 Voltage(V)\tA15 Current(A)\tA15 Power(W)\tGPU Frequency(MHz)\tGPU Temperature(C)\tGPU Voltage(V)\tGPU Current(A)\tGPU Power(W)\tRAM Voltage(V)\tRAM Current(A)\tRAM Power(W)" << endl;

	//Use bash timestamp function to collect timings	
	string cmd="echo $(date +'%s%N')'\t'";
  	struct timespec sleep;
  	sleep.tv_sec = 0;
	sleep.tv_nsec = 500000000;
	int len=cmd.size();

	// enable the sensors
	if (getNode->OpenINA231()) {
		cerr << "OpenINA231 error" << endl;
		exit(1);
	}
        
	//Wait 0.5 sec to initalise sensors
	nanosleep(&sleep,NULL);
	
	while(1) {

		//Get sensor information
                getNode->GetINA231();
         	
		//This makes sure that the time value pronted usign date is as close to the measurement to watt as possible, having a preallocated command string to just append the measurement value os the fastest way to generate the command to pass to system
		string output;
		for (i = 0; i < numLITTLEcores; i++)
                        output +=  getNode->GetCPUCurFreq(0+i) + '\t' + getNode->GetCPUTemp(0+i) + '\t';
		output += to_string(getNode->kfcuV) + '\t' + to_string(getNode->kfcuA) + '\t' + to_string(getNode->kfcuW) + '\t';
                
		for (i = 0; i < numbigcores; i++)
                        output +=  getNode->GetCPUCurFreq(4+i) + '\t' + getNode->GetCPUTemp(4+i) + '\t';
		output += to_string(getNode->armuV) + '\t' + to_string(getNode->armuA) + '\t' + to_string(getNode->armuW) + '\t';
		
		output += getNode->GetGPUCurFreq() + '\t' + getNode->GetCPUTemp(numLITTLEcores+numbigcores) + '\t' + to_string(getNode->g3duV) + '\t' + to_string(getNode->g3duA) + '\t' + to_string(getNode->g3duW) + '\t' + to_string(getNode->memuV) + '\t' + to_string(getNode->memuA) + '\t' + to_string(getNode->memuW);
		cmd += output;

         	system(cmd.c_str());
        	
		//then remove the watt values to reset the boilerplate echo command, length of original string is already stored
	        cmd.erase(len,output.length());
	
		nanosleep(&sleep,NULL);
	} 

	return 0;
}
