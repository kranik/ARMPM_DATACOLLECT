#include <sys/time.h>
#include "smartpower.h"
#include "ui_smartpower.h"
#include <QDate>
#include <QTime>
#include <unistd.h>

SmartPower::SmartPower(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::SmartPower)
{
    ui->setupUi(this);

    plugNPlay = new HID_PnP();

    ampereIndex = 0;
    wattIndex = 0;

    toggleFlag = 0;

    mIsLogging = false;

    mAmpereCurve = new QwtPlotCurve("ampere");
    WattCurve = new QwtPlotCurve("Watt");

    display_ampere_plot();

    ui->lcdNumber_watt->setNumDigits(6);
    ui->lcdNumber_wh->setNumDigits(7);

    ui->label_sw_version->setText("1.1.0");

    mOldAmpereMax = 0.0;
    mOldAmpereMin = 9.9;
    mOldWattMax = 0.0;
    mOldWattMin = 9.9;
    mStartMillisecond = 0;

    setFixedSize(geometry().width(), geometry().height());

    connect(this, SIGNAL(toggle_onoff_button_pressed()), plugNPlay, SLOT(toggle_onoff()));
    connect(this, SIGNAL(toggle_startstop_button_pressed()), plugNPlay, SLOT(toggle_startstop()));
    connect(plugNPlay, SIGNAL(hid_comm_data_update(unsigned char*)), this, SLOT(update_data_gui(unsigned char*)));
    connect(plugNPlay, SIGNAL(hid_comm_status_update(bool, bool, bool)), this, SLOT(update_status_gui(bool, bool, bool)));
    connect(plugNPlay, SIGNAL(hid_comm_version_update(unsigned char*)), this, SLOT(update_version_gui(unsigned char*)));
    connect(this, SIGNAL(plot_change_button_pressed()), this, SLOT(plot_change()));
}

SmartPower::~SmartPower()
{
    disconnect(this, SIGNAL(toggle_onoff_button_pressed()), plugNPlay, SLOT(toggle_onoff()));
    disconnect(this, SIGNAL(toggle_startstop_button_pressed()), plugNPlay, SLOT(toggle_startstop()));
    disconnect(plugNPlay, SIGNAL(hid_comm_data_update(unsigned char*)), this, SLOT(update_data_gui(unsigned char*)));
    disconnect(plugNPlay, SIGNAL(hid_comm_status_update(bool, bool, bool)), this, SLOT(update_status_gui(bool, bool, bool)));
    disconnect(plugNPlay, SIGNAL(hid_comm_version_update(unsigned char*)), this, SLOT(update_version_gui(unsigned char*)));
    disconnect(this, SIGNAL(plot_change_button_pressed()), this, SLOT(plot_change()));
    delete ui;
    delete plugNPlay;
}

void SmartPower::on_pushButton_plot_change_clicked()
{
    emit plot_change_button_pressed();
}

void SmartPower::on_pushButton_onoff_clicked()
{
    emit toggle_onoff_button_pressed();
    mIsLogging = false;
}

void SmartPower::on_pushButton_startstop_clicked()
{
	emit toggle_startstop_button_pressed();
	if (ui->checkBox_log->isChecked())
		log();
}

void SmartPower::log()
{
    if (!mIsLogging) {
    	mIsLogging = true;
        QDate date = QDate::currentDate();
        QTime time = QTime::currentTime();
        logFile.setFileName(date.toString(Qt::ISODate) 
			+ "_" + QString::number(time.hour())
			+ "h" + QString::number(time.minute()) 
			+ "m" + QString::number(time.second()) 
			+ "s.txt");
        logFile.open(QIODevice::WriteOnly | QIODevice::Text);
        mStartMillisecond = 0;
    } else {
        logFile.close();
        mIsLogging = false;
    }
}

void SmartPower::plot_change()
{
    if (toggleFlag == 0) {
        wattIndex = 0;
        mAmpereCurve->detach();
        display_watt_plot();
        ui->pushButton_plot_change->setText("Ampere Graph");
        toggleFlag = 1;
    } else {
        ampereIndex = 0;
        WattCurve->detach();
        display_ampere_plot();
        ui->pushButton_plot_change->setText("Watt Graph");
        toggleFlag = 0;
    }
}

void SmartPower::display_ampere_plot()
{
    ui->qwtPlot->setAxisScale(QwtPlot::yLeft, 0.0, 5.0);
    ui->qwtPlot->setAxisScale(QwtPlot::xBottom, 0, 100);
    ui->qwtPlot->setTitle("Smart Power");
    ui->qwtPlot->setAxisTitle(QwtPlot::yLeft, "Ampere");
    ui->qwtPlot->setAxisTitle(QwtPlot::xBottom, "100 msec");
    ui->qwtPlot->setCanvasBackground(QBrush(QColor(0, 0, 0)));

    mAmpereCurve->attach(ui->qwtPlot);
    mAmpereCurve->setPen(QColor(255, 0, 0));
}

void SmartPower::display_watt_plot()
{
    ui->qwtPlot->setAxisScale(QwtPlot::yLeft, 0.0, 30.0);
    ui->qwtPlot->setAxisScale(QwtPlot::xBottom, 0, 100);
    ui->qwtPlot->setTitle("Smart Power");
    ui->qwtPlot->setAxisTitle(QwtPlot::yLeft, "Watt");
    ui->qwtPlot->setAxisTitle(QwtPlot::xBottom, "100 msec");
    ui->qwtPlot->setCanvasBackground(QBrush(QColor(0, 0, 0)));

    WattCurve->attach(ui->qwtPlot);
    WattCurve->setPen(QColor(255, 0, 0));
}

void SmartPower::update_data_gui(unsigned char* raw)
{
    QTextStream out(&logFile);

    if (mIsLogging) {
        struct timeval te; 
        gettimeofday(&te, NULL);
        long long millisecond = te.tv_sec * 1000 + te.tv_usec / 1000;
        if (mStartMillisecond == 0)
            mStartMillisecond = millisecond;
        out << QString::number(millisecond - mStartMillisecond) << ", ";
    }

    char buf[7];
    strncpy(buf, (char*)&raw[2], 5);
    QString string = QString::fromAscii(buf, 5);
    ui->lcdNumber_voltage->display(string);
	
    if (mIsLogging)
        out << string << ", ";

    memset(buf, '\0', 7);
    strncpy(buf, (char*)&raw[10], 5);
    string = QString::fromAscii(buf, 5);
    ui->lcdNumber_ampere->display(string);

    if (mIsLogging)
        out << string << ", ";
 
    if (mIsRunning) {
        float current_ampere = string.toFloat();
        if (mOldAmpereMin > current_ampere) {
            mOldAmpereMin = current_ampere;
            ui->label_a_min->setText(string);
        }
        if (mOldAmpereMax < current_ampere) {
            mOldAmpereMax = current_ampere;
            ui->label_a_max->setText(string);
        }
    }

    if (toggleFlag == 0) {
        if (ampereIndex < 99) {
            yAmpereData[ampereIndex] = string.toFloat();
            xAmpereData[ampereIndex] = ampereIndex;
            ampereIndex++;
        } else {
            yAmpereData[99] = string.toFloat();
            for (int i = 1; i <= 99; i++) {
                yAmpereData[i - 1] = yAmpereData[i];
            }
        }

        mAmpereCurve->setSamples(xAmpereData, yAmpereData, ampereIndex);
        ui->qwtPlot->replot();
    }

    memset(buf, '\0', 7);
    strncpy(buf, (char*)&raw[17], 6);
    string = QString::fromAscii(buf, 6);
    ui->lcdNumber_watt->display(string);
 
    if (mIsLogging)
        out << string << "\n";

    if (mIsRunning) {
        float current_watt = string.toFloat();
        if (mOldWattMin > current_watt) {
            mOldWattMin = current_watt;
            ui->label_w_min->setText(string);
        }
        if (mOldWattMax < current_watt) {
            mOldWattMax = current_watt;
            ui->label_w_max->setText(string);
        }
    }

    if (toggleFlag == 1) {
        if (wattIndex < 99) {
            yWattData[wattIndex] = string.toFloat();
            xWattData[wattIndex] = wattIndex;
            wattIndex++;
        } else {
            yWattData[99] = string.toFloat();
            for (int i = 1; i <= 99; i++) {
                yWattData[i - 1] = yWattData[i];
            }
        }

        WattCurve->setSamples(xWattData, yWattData, wattIndex);
        ui->qwtPlot->replot();
    }
   
    memset(buf, '\0', 7);
    strncpy(buf, (char*)&raw[24], 7);
    string = QString::fromAscii(buf, 7);
    ui->lcdNumber_wh->display(string);

}

void SmartPower::update_status_gui(bool isConnected, bool isOn, bool isStart)
{
    mIsRunning = isStart;

    if (isConnected) {
   
        ui->deviceConnectedStatus->setText("Device Found: AttachedState = TRUE");
        ui->lcdNumber_voltage->setEnabled(true);
        ui->lcdNumber_ampere->setEnabled(true);
        ui->lcdNumber_watt->setEnabled(true);
        ui->lcdNumber_wh->setEnabled(true);

        ui->pushButton_onoff->setEnabled(true);

        if (isOn) {
            ui->pushButton_onoff->setEnabled(true);
            ui->pushButton_onoff->setText("Off");
            ui->pushButton_startstop->setEnabled(true);
            if (isStart) {
                ui->pushButton_startstop->setText("Stop");
                if (mIsLogging)
                    ui->checkBox_log->setText("logging...");
                else
                    ui->checkBox_log->setText("log");
            } else {
                ui->pushButton_startstop->setText("Start");
            }
        } else {
            mOldAmpereMax = 0.0;
            mOldAmpereMin = 9.9;
            mOldWattMax = 0.0;
            mOldWattMin = 9.9;
     
            ui->label_a_max->setText("-.--");
            ui->label_a_min->setText("-.--");
            ui->label_w_max->setText("--.--");
            ui->label_w_min->setText("--.--");
     
            ui->pushButton_startstop->setEnabled(false);
            ui->pushButton_onoff->setText("On");
            ui->checkBox_log->setText("log");
            mIsLogging = false;
        }
    } else {
        ui->deviceConnectedStatus->setText("Device Not Detected: Verify Connection/Correct Firmware");
        ui->lcdNumber_voltage->setEnabled(false);
        ui->lcdNumber_ampere->setEnabled(false);
        ui->lcdNumber_watt->setEnabled(false);
        ui->lcdNumber_wh->setEnabled(false);

        ui->pushButton_onoff->setEnabled(false);
        ui->pushButton_startstop->setEnabled(false);

        ampereIndex = 0;
        wattIndex = 0;
    }
}

void SmartPower::update_version_gui(unsigned char* raw)
{
    char buf[17];
    strncpy(buf, (char*)&raw[12], 5);
    QString string = QString::fromAscii(buf, 5);
    ui->label_fw_version->setText(string);
}
