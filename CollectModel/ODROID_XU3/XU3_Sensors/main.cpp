// coded by chan at 2014-09-04

#define NUMCORES	8

#include "getnode.h"
#include <iostream> // cout, endl
#include <cstdlib>	// atoi
#include <csignal>
#include <unistd.h>	// sleep
#include <ctime>
#include <iomanip>	// cout format
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

	cout << "#Timestamp\tA7 Voltage(V)\tA7 Current(A)\tA7 Power(W)\tA15 Voltage(V)\tA15 Current(A)\tA15 Power(w)\tGPU Voltage(V)\tGPU Current(A)\tGPU Power(W)\tRAM Voltage(V)\tRAM Current(A)\tRAM Power(W)" << endl;
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
	else {
		cerr << "This loops forever until press <Ctrl-C>!" << endl;
	}
        //Wait 0.5 sec to initalise sensors
	nanosleep(&sleep,NULL);

	while(1) {
		
		getNode->GetINA231();
		
		a15Volt = to_string(getNode->armuV);
    		a15Ampere = to_string(getNode->armuA);
    		a15Watt = to_string(getNode->armuW);

    		a7Volt = to_string(getNode->kfcuV);
    		a7Ampere = to_string(getNode->kfcuA);
    		a7Watt = to_string(getNode->kfcuW);

    		gpuVolt = to_string(getNode->g3duV);
    		gpuAmpere = to_string(getNode->g3duA);
    		gpuWatt = to_string(getNode->g3duW);

    		memVolt = to_string(getNode->memuV);
    		memAmpere = to_string(getNode->memuA);
    		memWatt = to_string(getNode->memuW);

         	//need to build the command with the now read watt value, system only accepts const char* so need to convert string
         	//This makes sure that the time value pronted usign date is as close to the measurement to watt as possible, having a preallocated command string to just append the watt value os the fastest way to generate the command to pass to system
		string output = a7Volt + '\t' + a7Ampere + '\t' + a7Watt + '\t' + a15Volt + '\t' + a15Ampere + '\t' + a15Watt + '\t' + gpuVolt + '\t' + gpuAmpere + '\t' + gpuWatt + '\t' + memVolt + '\t' + memAmpere + '\t' + memWatt;
		cmd.append(output);

         	system(cmd.c_str());
        	//then remove the watt values to reset the boilerplate echo command, length of original string is already stored
	        cmd.erase(len,output.length());
		
	
		nanosleep(&sleep,NULL);
	} 

	return 0;
}
