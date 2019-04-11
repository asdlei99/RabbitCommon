#-------------------------------------------------
#
# Project created by QtCreator 2019-04-11T09:59:18
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = RabbitCommon
TEMPLATE = subdirs

lib.subdir = Src
App.depends = lib
CONFIG *= ordered
SUBDIRS = lib App

isEmpty(PREFIX) {
    qnx : PREFIX = /tmp
    else : android : PREFIX = /.
    else : unnix : PREFIX = /usr/local
    else : PREFIX = $$OUT_PWD/../install
}

# The following define makes your compiler emit warnings if you use
# any feature of Qt which has been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

CONFIG += c++11

DISTFILES += Authors.md \
    Authors_zh_CN.md \
    ChangeLog.md \
    ChangeLog_zh_CN.md \
    License.md

OTHER_FILES += CMakeLists.txt \
    .travis.yml \
    appveyor.yml \
    ci/* \
    tag.sh

other.files = $$DISTFILES
other.path = $$PREFIX
other.CONFIG += no_check_exist 
!android : INSTALLS += other
