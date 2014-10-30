#include "hid_pnp.h"
#include <unistd.h>
#include <QDebug>

#define REQUEST_DATA        0x37
#define REQUEST_STARTSTOP   0x80
#define REQUEST_STATUS      0x81
#define REQUEST_ONOFF       0x82
#define REQUEST_VERSION     0x83

HID_PnP::HID_PnP(QObject *parent) : QObject(parent) {
    isConnected = false;
    toggleOnOff = 0;
    toggleStartStop = 0;

    device = NULL;
    memset((void*)&buf[2], 0x00, sizeof(buf) - 2);
    
    timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(PollUSB()));

    timer->start(250);
}

HID_PnP::~HID_PnP() {
    disconnect(timer, SIGNAL(timeout()), this, SLOT(PollUSB()));
}

void HID_PnP::PollUSB()
{
    buf[0] = 0x00;

    if (isConnected == false) {
        device = hid_open(0x04d8, 0x003f, NULL);

        if (device) {
            memset((void*)&buf[2], 0x00, sizeof(buf) - 2);
            isConnected = true;
            hid_set_nonblocking(device, true);

            buf[1] = REQUEST_VERSION;
            
            lastCommand = buf[1];

            if (hid_write(device, buf, sizeof(buf)) == -1) {
                CloseDevice();
                return;
            }

            if (hid_read(device, buf, sizeof(buf)) == -1) {
                CloseDevice();
                return;
            }
        }
    } else {
        if (toggleStartStop == true) {
            toggleStartStop = false;

            unsigned char cmd[MAX_STR] = {0x00,};
            cmd[1] = REQUEST_STARTSTOP;
            
            if (hid_write(device, cmd, sizeof(cmd)) == -1) {
                CloseDevice();
                return;
            }
        }

        if (toggleOnOff == true) {
            toggleOnOff = false;

            unsigned char cmd[MAX_STR] = {0x00,};
            cmd[1] = REQUEST_ONOFF;
            
            if (hid_write(device, cmd, sizeof(cmd)) == -1) {
                CloseDevice();
                return;
            }
        }
        
        lastCommand = buf[1];

        if (!skip) {
            if (hid_write(device, buf, sizeof(buf)) == -1) {
                CloseDevice();
                return;
            }
        }

#ifdef __linux__            
        usleep(10);
#else
        _sleep(10);
#endif

        if (hid_read(device, buf, sizeof(buf)) == -1) {
            CloseDevice();
            return;
        }
        
        if (lastCommand != buf[0]) {
            skip = true;
        } else {
            if (buf[0] == REQUEST_VERSION) {
                hid_comm_version_update(buf);
                buf[1] = REQUEST_STATUS;
                skip = false;
                timer->start(100);
                count = 0;
                memset(buf2, 0x00, MAX_STR);
            } else if (buf[0] == REQUEST_DATA) {
                buf[1] = REQUEST_STATUS;
                memcpy(buf2, buf, MAX_STR);
            } else if (buf[0] == REQUEST_STATUS) {
                startStopStatus = (buf[1] == 0x01);
                onOffStatus = (buf[2] == 0x01);
                if (count == 9)
                    buf[1] = REQUEST_STATUS;
                else
                    buf[1] = REQUEST_DATA;
                hid_comm_status_update(isConnected, onOffStatus, startStopStatus);
                count = 0;
            } else {
                if (lastCommand == REQUEST_STATUS)
                    buf[1] = REQUEST_DATA;
                else 
                    buf[1] = REQUEST_STATUS;
            }
            skip = false;
        }

        hid_comm_data_update(buf2);
        count++;
    }
}

void HID_PnP::toggle_onoff() {
    toggleOnOff = true;
}

void HID_PnP::toggle_startstop() {
    toggleStartStop = true;
}

void HID_PnP::CloseDevice() {
    hid_close(device);
    device = NULL;
    isConnected = false;
    toggleOnOff = 0;
    toggleStartStop = 0;
    hid_comm_status_update(isConnected, onOffStatus, startStopStatus);
    hid_comm_data_update(buf);
    timer->start(250);
}
