#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QRectF>
#include <QtCore>
#include "imagecropper.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QString inFilename;
    QString outFilename;
    if (argc == 1) {
        // Debug
        inFilename = QString("/home/chris/Code/testqml2/2016-03-30-041842_1920x1080_scrot.png");
        outFilename = QString("/home/chris/Code/testqml2/2016-03-30-041842_1920x1080_scrot-cropped.png");
    } else {
        QCommandLineParser parser;
        parser.setApplicationDescription("Test helper");
        parser.addHelpOption();
        parser.addVersionOption();
        parser.addPositionalArgument("source", "Source filename to crop.");
        parser.addPositionalArgument("output", "Output filename.");
        parser.process(app);
        const QStringList args = parser.positionalArguments();

        inFilename = args.at(0);
        outFilename = args.at(1);
    }

    ImageCropper imageCropper(inFilename, outFilename);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    QObject* root = engine.rootObjects()[0];
    root->setProperty("inFilename", QFileInfo(inFilename).absoluteFilePath());

    QObject::connect(root, SIGNAL(regionSelected(QRectF)), &imageCropper, SLOT(cropImage(QRectF)));
    QObject::connect(root, SIGNAL(cancel(int)), &imageCropper, SLOT(quitApp(int)));

    return app.exec();
}

