#include "imagecropper.h"
#include <QDebug>
#include <QRectF>
#include <QImage>

ImageCropper::ImageCropper(QString inFilename, QString outFilename)
{
    this->inFilename = inFilename;
    this->outFilename = outFilename;
}

void ImageCropper::cropImage(QRectF region)
{
    qDebug() << "cropImage";
    qDebug() << region;

    QImage original(this->inFilename);
    QImage cropped = original.copy(region.toRect());
    cropped.save(this->outFilename);
}

void ImageCropper::quitApp(int exitCode)
{
    qDebug() << "quitApp";
    qDebug() << exitCode;

    QCoreApplication::exit(exitCode);
}

