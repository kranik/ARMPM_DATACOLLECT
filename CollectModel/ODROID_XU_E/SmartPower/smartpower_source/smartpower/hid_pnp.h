#ifndef HID_PNP_H
#define HID_PNP_H

#include <QObject>
#include <QTimer>
#include "../HIDAPI/hidapi.h"

#include <wchar.h>
#include <string.h>
#include <stdlib.h>

#define MAX_STR 65

class HID_PnP : public QObject
{
    Q_OBJECT
public:
    explicit HID_PnP(QObject *parent = 0);
    ~HID_PnP();

signals:
    void hid_comm_data_update(unsigned char* raw);
    void hid_comm_status_update(bool isConnected, bool isOn, bool isStart);
    void hid_comm_version_update(unsigned char* raw);

public slots:
    void toggle_onoff();
    void toggle_startstop();
    void PollUSB();

private:
    bool isConnected;
    bool onOffStatus;
    bool startStopStatus;
    bool toggleStartStop;
    bool toggleOnOff;

    hid_device *device;
    QTimer *timer;
    bool skip;
    int lastCommand;
    unsigned char buf[MAX_STR];
    unsigned char buf2[MAX_STR];

    void CloseDevice();
    int count;
};

#endif // HID_PNP_H
