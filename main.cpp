#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "dbdriver4.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("vksoft");
    QCoreApplication::setApplicationName("vkStat");

    QScopedPointer<DbDriver4> singletonprocessor(new DbDriver4);
    qmlRegisterSingletonInstance("com.singleton.dbdriver4", 1, 0, "Db", singletonprocessor.get());

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("applicationDirPath", QCoreApplication::applicationDirPath());

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("vkStat", "Main");

    return QCoreApplication::exec();
}
