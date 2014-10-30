/****************************************************************************
** Meta object code from reading C++ file 'smartpower.h'
**
** Created: Wed Feb 19 17:26:09 2014
**      by: The Qt Meta Object Compiler version 63 (Qt 4.8.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../smartpower.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'smartpower.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_SmartPower[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
      10,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       3,       // signalCount

 // signals: signature, parameters, type, tag, flags
      11,   41,   41,   41, 0x05,
      42,   41,   41,   41, 0x05,
      76,   41,   41,   41, 0x05,

 // slots: signature, parameters, type, tag, flags
     105,  137,   41,   41, 0x0a,
     141,  175,   41,   41, 0x0a,
     200,  137,   41,   41, 0x0a,
     235,   41,   41,   41, 0x0a,
     249,   41,   41,   41, 0x08,
     279,   41,   41,   41, 0x08,
     313,   41,   41,   41, 0x08,

       0        // eod
};

static const char qt_meta_stringdata_SmartPower[] = {
    "SmartPower\0toggle_onoff_button_pressed()\0"
    "\0toggle_startstop_button_pressed()\0"
    "plot_change_button_pressed()\0"
    "update_data_gui(unsigned char*)\0raw\0"
    "update_status_gui(bool,bool,bool)\0"
    "isConnected,isOn,isStart\0"
    "update_version_gui(unsigned char*)\0"
    "plot_change()\0on_pushButton_onoff_clicked()\0"
    "on_pushButton_startstop_clicked()\0"
    "on_pushButton_plot_change_clicked()\0"
};

void SmartPower::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        SmartPower *_t = static_cast<SmartPower *>(_o);
        switch (_id) {
        case 0: _t->toggle_onoff_button_pressed(); break;
        case 1: _t->toggle_startstop_button_pressed(); break;
        case 2: _t->plot_change_button_pressed(); break;
        case 3: _t->update_data_gui((*reinterpret_cast< unsigned char*(*)>(_a[1]))); break;
        case 4: _t->update_status_gui((*reinterpret_cast< bool(*)>(_a[1])),(*reinterpret_cast< bool(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3]))); break;
        case 5: _t->update_version_gui((*reinterpret_cast< unsigned char*(*)>(_a[1]))); break;
        case 6: _t->plot_change(); break;
        case 7: _t->on_pushButton_onoff_clicked(); break;
        case 8: _t->on_pushButton_startstop_clicked(); break;
        case 9: _t->on_pushButton_plot_change_clicked(); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData SmartPower::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject SmartPower::staticMetaObject = {
    { &QMainWindow::staticMetaObject, qt_meta_stringdata_SmartPower,
      qt_meta_data_SmartPower, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &SmartPower::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *SmartPower::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *SmartPower::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_SmartPower))
        return static_cast<void*>(const_cast< SmartPower*>(this));
    return QMainWindow::qt_metacast(_clname);
}

int SmartPower::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QMainWindow::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 10)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    }
    return _id;
}

// SIGNAL 0
void SmartPower::toggle_onoff_button_pressed()
{
    QMetaObject::activate(this, &staticMetaObject, 0, 0);
}

// SIGNAL 1
void SmartPower::toggle_startstop_button_pressed()
{
    QMetaObject::activate(this, &staticMetaObject, 1, 0);
}

// SIGNAL 2
void SmartPower::plot_change_button_pressed()
{
    QMetaObject::activate(this, &staticMetaObject, 2, 0);
}
QT_END_MOC_NAMESPACE
