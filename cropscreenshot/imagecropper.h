#ifndef IMAGECROPPER_H
#define IMAGECROPPER_H
#include <QtCore>
#include <QRectF>


class ImageCropper : public QObject
{
    Q_OBJECT
public:
    ImageCropper(QString inFilename, QString outFilename);

public slots:
    void cropImage(QRectF region);
    void quitApp(int exitCode);
private:
    QString inFilename;
    QString outFilename;
};

#endif // IMAGECROPPER_H
