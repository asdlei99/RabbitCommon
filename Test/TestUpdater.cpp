#include "TestUpdater.h"
#include "FrmUpdater.h"
#include "RabbitCommonTools.h"
#include <QApplication>
#include <QTest>
#include <QLoggingCategory>
#include <QLabel>

static Q_LOGGING_CATEGORY(log, "RabbitCommon.Test.Updater")

CTestUpdater::CTestUpdater(QObject *parent)
    : QObject{parent}
{}

void CTestUpdater::TestCheckRedirectJson()
{
    QVector<QUrl> urls;
    urls << QUrl::fromLocalFile("data/redirect.json");
    CFrmUpdater* pUpdater = new CFrmUpdater(urls);
    pUpdater->SetVersion("v3.0.0");
    pUpdater->show();
    QTest::qWait(100);
    QLabel* pState = pUpdater->findChild<QLabel*>("lbState");
    QVERIFY(pState->text() == tr("There is laster version"));
    pUpdater->close();
    //QTest::keyPress(pUpdater, Qt::Key_C, Qt::AltModifier);
    return;
}

void CTestUpdater::TestCheckUpdateJson()
{
    QVector<QUrl> urls;
    urls << QUrl::fromLocalFile("data/redirect.json");
    CFrmUpdater* pUpdater = new CFrmUpdater(urls);
    pUpdater->SetVersion("v0.0.25");
    pUpdater->show();
    
    QTest::qWait(5000);
    QLabel* pState = pUpdater->findChild<QLabel*>("lbState");
    QVERIFY(pState->text() == tr("There is a new version, is it updated?"));
    QTest::keyPress(pUpdater, Qt::Key_O, Qt::AltModifier);
    QTest::qWait(5000);
    QTest::keyPress(pUpdater, Qt::Key_C, Qt::AltModifier);
    return;
}

QTEST_MAIN(CTestUpdater)

/*
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setQuitOnLastWindowClosed(true);

    RabbitCommon::CTools::Instance()->Init();

    CTestUpdater test;
    
    int nRet = test.TestCheckRedirectJson();
    if(nRet)
        return nRet;
    
    nRet = test.TestCheckUpdateJson();
    if(nRet)
        return nRet;

    return app.exec();
}//*/
