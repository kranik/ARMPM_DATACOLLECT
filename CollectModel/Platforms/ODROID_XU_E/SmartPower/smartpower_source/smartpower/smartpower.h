#ifndef POWERMETER_H
#define POWERMETER_H

#include <QMainWindow>
#include <QFile>
#include <qwt_plot.h>
#include <qwt_plot_curve.h>
#include "hid_pnp.h"

namespace Ui {
    class SmartPower;
}

class SmartPower : public QMainWindow
{
    Q_OBJECT

public:
    explicit SmartPower(QWidget *parent = 0);
    ~SmartPower();

private:
    Ui::SmartPower *ui;
    HID_PnP *plugNPlay;
    double xAmpereData[100];
    double yAmpereData[100];
    double xWattData[100];
    double yWattData[100];
    int ampereIndex;
    int wattIndex;
    int toggleFlag;
    QwtPlotCurve *mAmpereCurve;
    QwtPlotCurve *WattCurve;
    bool mIsLogging;
    bool mIsRunning;
    int timeIndex;
    float mOldAmpereMax;
    float mOldAmpereMin;
    float mOldWattMax;
    float mOldWattMin;
    long long mStartMillisecond;
    QFile logFile;
    void display_ampere_plot();
    void display_watt_plot();
	void log();

public slots:
    void update_data_gui(unsigned char* raw);
    void update_status_gui(bool isConnected, bool isOn, bool isStart);
    void update_version_gui(unsigned char* raw);
    void plot_change();

signals:
    void toggle_onoff_button_pressed();
    void toggle_startstop_button_pressed();
    void plot_change_button_pressed();

private slots:
    void on_pushButton_onoff_clicked();
    void on_pushButton_startstop_clicked();
    void on_pushButton_plot_change_clicked();
};

#endif // POWERMETER_H 
