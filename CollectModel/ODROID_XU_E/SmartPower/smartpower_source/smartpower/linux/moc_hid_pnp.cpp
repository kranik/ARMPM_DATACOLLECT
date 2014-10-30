/****************************************************************************
** Meta object code from reading C++ file 'hid_pnp.h'
**
** Created: Wed Feb 19 17:26:11 2014
**      by: The Qt Meta Object Compiler version 63 (Qt 4.8.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../hid_pnp.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'hid_pnp.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_HID_PnP[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       6,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       3,       // signalCount

 // signals: signature, parameters, type, tag, flags
       8,   45,   49,   49, 0x05,
      50,   89,   49,   49, 0x05,
     114,   45,   49,   49, 0x05,

 // slots: signature, parameters, type, tag, flags
     154,   49,   49,   49, 0x0a,
     169,   49,   49,   49, 0x0a,
     188,   49,   49,   49, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_HID_PnP[] = {
    "HID_PnP\0hid_comm_data_update(unsigned char*)\0"
    "raw\0\0hid_comm_status_update(bool,bool,bool)\0"
    "isConnected,isOn,isStart\0"
    "hid_comm_version_update(unsigned char*)\0"
    "toggle_onoff()\0toggle_startstop()\0"
    "PollUSB()\0"
};

void HID_PnP::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        HID_PnP *_t = static_cast<HID_PnP *>(_o);
        switch (_id) {
        case 0: _t->hid_comm_data_update((*reinterpret_cast< unsigned char*(*)>(_a[1]))); break;
        case 1: _t->hid_comm_status_update((*reinterpret_cast< bool(*)>(_a[1])),(*reinterpret_cast< bool(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3]))); break;
        case 2: _t->hid_comm_version_update((*reinterpret_cast< unsigned char*(*)>(_a[1]))); break;
        case 3: _t->toggle_onoff(); break;
        case 4: _t->toggle_startstop(); break;
        case 5: _t->PollUSB(); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData HID_PnP::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject HID_PnP::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_HID_PnP,
      qt_meta_data_HID_PnP, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &HID_PnP::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *HID_PnP::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *HID_PnP::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_HID_PnP))
        return static_cast<void*>(const_cast< HID_PnP*>(this));
    return QObject::qt_metacast(_clname);
}

int HID_PnP::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 6)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
    }
    return _id;
}

// SIGNAL 0
void HID_PnP::hid_comm_data_update(unsigned char * _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void HID_PnP::hid_comm_status_update(bool _t1, bool _t2, bool _t3)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)), const_cast<void*>(reinterpret_cast<const void*>(&_t3)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void HID_PnP::hid_comm_version_update(unsigned char * _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}
QT_END_MOC_NAMESPACE
