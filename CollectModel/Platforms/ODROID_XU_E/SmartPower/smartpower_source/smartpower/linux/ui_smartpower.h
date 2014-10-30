/********************************************************************************
** Form generated from reading UI file 'smartpower.ui'
**
** Created: Wed Feb 19 17:26:01 2014
**      by: Qt User Interface Compiler version 4.8.1
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_SMARTPOWER_H
#define UI_SMARTPOWER_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QCheckBox>
#include <QtGui/QHeaderView>
#include <QtGui/QLCDNumber>
#include <QtGui/QLabel>
#include <QtGui/QLineEdit>
#include <QtGui/QMainWindow>
#include <QtGui/QMenuBar>
#include <QtGui/QPushButton>
#include <QtGui/QStatusBar>
#include <QtGui/QWidget>
#include "qwt_plot.h"

QT_BEGIN_NAMESPACE

class Ui_SmartPower
{
public:
    QWidget *centralWidget;
    QPushButton *pushButton_startstop;
    QLabel *label_3;
    QLineEdit *deviceConnectedStatus;
    QLabel *label_valtage;
    QLCDNumber *lcdNumber_voltage;
    QLCDNumber *lcdNumber_ampere;
    QLabel *label_ampere;
    QLCDNumber *lcdNumber_watt;
    QLabel *label_watt;
    QLCDNumber *lcdNumber_wh;
    QLabel *label_wh;
    QPushButton *pushButton_onoff;
    QwtPlot *qwtPlot;
    QLabel *label_sw_version;
    QLabel *label_4;
    QLabel *label_fw_version;
    QLabel *label_5;
    QLabel *label_a_max_static;
    QLabel *label_a_min_static;
    QLabel *label_w_max_static;
    QLabel *label_w_min_static;
    QLabel *label_a_max;
    QLabel *label_a_min;
    QLabel *label_w_max;
    QLabel *label_w_min;
    QPushButton *pushButton_plot_change;
    QCheckBox *checkBox_log;
    QMenuBar *menuBar;
    QStatusBar *statusBar;

    void setupUi(QMainWindow *SmartPower)
    {
        if (SmartPower->objectName().isEmpty())
            SmartPower->setObjectName(QString::fromUtf8("SmartPower"));
        SmartPower->resize(793, 569);
        centralWidget = new QWidget(SmartPower);
        centralWidget->setObjectName(QString::fromUtf8("centralWidget"));
        pushButton_startstop = new QPushButton(centralWidget);
        pushButton_startstop->setObjectName(QString::fromUtf8("pushButton_startstop"));
        pushButton_startstop->setEnabled(false);
        pushButton_startstop->setGeometry(QRect(110, 50, 71, 31));
        label_3 = new QLabel(centralWidget);
        label_3->setObjectName(QString::fromUtf8("label_3"));
        label_3->setEnabled(true);
        label_3->setGeometry(QRect(400, 10, 41, 21));
        label_3->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
        deviceConnectedStatus = new QLineEdit(centralWidget);
        deviceConnectedStatus->setObjectName(QString::fromUtf8("deviceConnectedStatus"));
        deviceConnectedStatus->setEnabled(true);
        deviceConnectedStatus->setGeometry(QRect(20, 10, 371, 20));
        deviceConnectedStatus->setReadOnly(true);
        label_valtage = new QLabel(centralWidget);
        label_valtage->setObjectName(QString::fromUtf8("label_valtage"));
        label_valtage->setGeometry(QRect(34, 98, 51, 31));
        label_valtage->setTextFormat(Qt::AutoText);
        lcdNumber_voltage = new QLCDNumber(centralWidget);
        lcdNumber_voltage->setObjectName(QString::fromUtf8("lcdNumber_voltage"));
        lcdNumber_voltage->setGeometry(QRect(30, 130, 191, 51));
        lcdNumber_voltage->setFrameShape(QFrame::Box);
        lcdNumber_voltage->setFrameShadow(QFrame::Raised);
        lcdNumber_voltage->setSmallDecimalPoint(false);
        lcdNumber_voltage->setSegmentStyle(QLCDNumber::Flat);
        lcdNumber_ampere = new QLCDNumber(centralWidget);
        lcdNumber_ampere->setObjectName(QString::fromUtf8("lcdNumber_ampere"));
        lcdNumber_ampere->setGeometry(QRect(30, 210, 191, 51));
        lcdNumber_ampere->setSegmentStyle(QLCDNumber::Flat);
        label_ampere = new QLabel(centralWidget);
        label_ampere->setObjectName(QString::fromUtf8("label_ampere"));
        label_ampere->setGeometry(QRect(34, 187, 51, 21));
        lcdNumber_watt = new QLCDNumber(centralWidget);
        lcdNumber_watt->setObjectName(QString::fromUtf8("lcdNumber_watt"));
        lcdNumber_watt->setGeometry(QRect(30, 330, 191, 51));
        lcdNumber_watt->setSegmentStyle(QLCDNumber::Flat);
        label_watt = new QLabel(centralWidget);
        label_watt->setObjectName(QString::fromUtf8("label_watt"));
        label_watt->setGeometry(QRect(32, 307, 31, 21));
        lcdNumber_wh = new QLCDNumber(centralWidget);
        lcdNumber_wh->setObjectName(QString::fromUtf8("lcdNumber_wh"));
        lcdNumber_wh->setGeometry(QRect(30, 451, 191, 51));
        lcdNumber_wh->setSegmentStyle(QLCDNumber::Flat);
        lcdNumber_wh->setProperty("value", QVariant(0));
        label_wh = new QLabel(centralWidget);
        label_wh->setObjectName(QString::fromUtf8("label_wh"));
        label_wh->setGeometry(QRect(31, 428, 61, 21));
        pushButton_onoff = new QPushButton(centralWidget);
        pushButton_onoff->setObjectName(QString::fromUtf8("pushButton_onoff"));
        pushButton_onoff->setEnabled(false);
        pushButton_onoff->setGeometry(QRect(20, 50, 71, 31));
        qwtPlot = new QwtPlot(centralWidget);
        qwtPlot->setObjectName(QString::fromUtf8("qwtPlot"));
        qwtPlot->setGeometry(QRect(310, 130, 440, 381));
        label_sw_version = new QLabel(centralWidget);
        label_sw_version->setObjectName(QString::fromUtf8("label_sw_version"));
        label_sw_version->setEnabled(true);
        label_sw_version->setGeometry(QRect(560, 10, 41, 21));
        label_sw_version->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
        label_4 = new QLabel(centralWidget);
        label_4->setObjectName(QString::fromUtf8("label_4"));
        label_4->setEnabled(true);
        label_4->setGeometry(QRect(470, 10, 91, 21));
        label_4->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
        label_fw_version = new QLabel(centralWidget);
        label_fw_version->setObjectName(QString::fromUtf8("label_fw_version"));
        label_fw_version->setEnabled(true);
        label_fw_version->setGeometry(QRect(710, 10, 41, 21));
        label_fw_version->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
        label_5 = new QLabel(centralWidget);
        label_5->setObjectName(QString::fromUtf8("label_5"));
        label_5->setEnabled(true);
        label_5->setGeometry(QRect(620, 10, 91, 21));
        label_5->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
        label_a_max_static = new QLabel(centralWidget);
        label_a_max_static->setObjectName(QString::fromUtf8("label_a_max_static"));
        label_a_max_static->setGeometry(QRect(130, 267, 41, 16));
        label_a_max_static->setMinimumSize(QSize(41, 16));
        label_a_max_static->setMaximumSize(QSize(41, 16777215));
        label_a_min_static = new QLabel(centralWidget);
        label_a_min_static->setObjectName(QString::fromUtf8("label_a_min_static"));
        label_a_min_static->setGeometry(QRect(33, 267, 41, 16));
        label_a_min_static->setMinimumSize(QSize(41, 16));
        label_a_min_static->setMaximumSize(QSize(41, 16777215));
        label_w_max_static = new QLabel(centralWidget);
        label_w_max_static->setObjectName(QString::fromUtf8("label_w_max_static"));
        label_w_max_static->setGeometry(QRect(34, 387, 41, 21));
        label_w_min_static = new QLabel(centralWidget);
        label_w_min_static->setObjectName(QString::fromUtf8("label_w_min_static"));
        label_w_min_static->setGeometry(QRect(134, 389, 31, 16));
        label_a_max = new QLabel(centralWidget);
        label_a_max->setObjectName(QString::fromUtf8("label_a_max"));
        label_a_max->setGeometry(QRect(67, 259, 61, 31));
        QFont font;
        font.setPointSize(14);
        font.setBold(true);
        font.setItalic(false);
        font.setWeight(75);
        label_a_max->setFont(font);
        label_a_min = new QLabel(centralWidget);
        label_a_min->setObjectName(QString::fromUtf8("label_a_min"));
        label_a_min->setGeometry(QRect(169, 259, 71, 31));
        label_a_min->setFont(font);
        label_w_max = new QLabel(centralWidget);
        label_w_max->setObjectName(QString::fromUtf8("label_w_max"));
        label_w_max->setGeometry(QRect(70, 381, 71, 31));
        label_w_max->setFont(font);
        label_w_min = new QLabel(centralWidget);
        label_w_min->setObjectName(QString::fromUtf8("label_w_min"));
        label_w_min->setGeometry(QRect(170, 381, 66, 31));
        label_w_min->setFont(font);
        pushButton_plot_change = new QPushButton(centralWidget);
        pushButton_plot_change->setObjectName(QString::fromUtf8("pushButton_plot_change"));
        pushButton_plot_change->setEnabled(true);
        pushButton_plot_change->setGeometry(QRect(483, 50, 131, 51));
        checkBox_log = new QCheckBox(centralWidget);
        checkBox_log->setObjectName(QString::fromUtf8("checkBox_log"));
        checkBox_log->setGeometry(QRect(210, 50, 97, 30));
        SmartPower->setCentralWidget(centralWidget);
        pushButton_onoff->raise();
        pushButton_startstop->raise();
        label_3->raise();
        deviceConnectedStatus->raise();
        label_valtage->raise();
        lcdNumber_voltage->raise();
        lcdNumber_ampere->raise();
        label_ampere->raise();
        lcdNumber_watt->raise();
        label_watt->raise();
        lcdNumber_wh->raise();
        label_wh->raise();
        qwtPlot->raise();
        label_sw_version->raise();
        label_4->raise();
        label_fw_version->raise();
        label_5->raise();
        label_a_max_static->raise();
        label_a_min_static->raise();
        label_w_max_static->raise();
        label_w_min_static->raise();
        label_a_max->raise();
        label_a_min->raise();
        label_w_max->raise();
        label_w_min->raise();
        pushButton_plot_change->raise();
        checkBox_log->raise();
        menuBar = new QMenuBar(SmartPower);
        menuBar->setObjectName(QString::fromUtf8("menuBar"));
        menuBar->setGeometry(QRect(0, 0, 793, 26));
        SmartPower->setMenuBar(menuBar);
        statusBar = new QStatusBar(SmartPower);
        statusBar->setObjectName(QString::fromUtf8("statusBar"));
        SmartPower->setStatusBar(statusBar);

        retranslateUi(SmartPower);

        QMetaObject::connectSlotsByName(SmartPower);
    } // setupUi

    void retranslateUi(QMainWindow *SmartPower)
    {
        SmartPower->setWindowTitle(QApplication::translate("SmartPower", "Smart Power", 0, QApplication::UnicodeUTF8));
        pushButton_startstop->setText(QApplication::translate("SmartPower", "Start", 0, QApplication::UnicodeUTF8));
        label_3->setText(QApplication::translate("SmartPower", "Status", 0, QApplication::UnicodeUTF8));
        deviceConnectedStatus->setText(QApplication::translate("SmartPower", "Device Not Detected: Verify Connection/Correct Firmware", 0, QApplication::UnicodeUTF8));
        label_valtage->setText(QApplication::translate("SmartPower", "Voltage", 0, QApplication::UnicodeUTF8));
        label_ampere->setText(QApplication::translate("SmartPower", "Ampere", 0, QApplication::UnicodeUTF8));
        label_watt->setText(QApplication::translate("SmartPower", "Watt", 0, QApplication::UnicodeUTF8));
        label_wh->setText(QApplication::translate("SmartPower", "Watt/hour", 0, QApplication::UnicodeUTF8));
        pushButton_onoff->setText(QApplication::translate("SmartPower", "On", 0, QApplication::UnicodeUTF8));
        label_sw_version->setText(QApplication::translate("SmartPower", "n/a", 0, QApplication::UnicodeUTF8));
        label_4->setText(QApplication::translate("SmartPower", "S/W Version :", 0, QApplication::UnicodeUTF8));
        label_fw_version->setText(QApplication::translate("SmartPower", "n/a", 0, QApplication::UnicodeUTF8));
        label_5->setText(QApplication::translate("SmartPower", "F/W Version :", 0, QApplication::UnicodeUTF8));
        label_a_max_static->setText(QApplication::translate("SmartPower", "Max : ", 0, QApplication::UnicodeUTF8));
        label_a_min_static->setText(QApplication::translate("SmartPower", "Min : ", 0, QApplication::UnicodeUTF8));
        label_w_max_static->setText(QApplication::translate("SmartPower", "Max : ", 0, QApplication::UnicodeUTF8));
        label_w_min_static->setText(QApplication::translate("SmartPower", "Min : ", 0, QApplication::UnicodeUTF8));
        label_a_max->setText(QString());
        label_a_min->setText(QString());
        label_w_max->setText(QString());
        label_w_min->setText(QString());
        pushButton_plot_change->setText(QApplication::translate("SmartPower", "Watt Graph", 0, QApplication::UnicodeUTF8));
        checkBox_log->setText(QApplication::translate("SmartPower", "log", 0, QApplication::UnicodeUTF8));
    } // retranslateUi

};

namespace Ui {
    class SmartPower: public Ui_SmartPower {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_SMARTPOWER_H
