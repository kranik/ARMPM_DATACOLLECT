#include <QtGui/QApplication>
#include "smartpower.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    SmartPower w;
    w.show();

    return a.exec();
}
