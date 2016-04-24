/********************************************************************************
** Form generated from reading UI file 'mazedisplay.ui'
**
** Created by: Qt User Interface Compiler version 4.8.6
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_MAZEDISPLAY_H
#define UI_MAZEDISPLAY_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QHeaderView>
#include <QtGui/QMainWindow>
#include <QtGui/QMenuBar>
#include <QtGui/QStatusBar>
#include <QtGui/QToolBar>
#include <QtGui/QWidget>

QT_BEGIN_NAMESPACE

class Ui_MazeDisplay
{
public:
    QMenuBar *menuBar;
    QToolBar *mainToolBar;
    QWidget *centralWidget;
    QStatusBar *statusBar;

    void setupUi(QMainWindow *MazeDisplay)
    {
        if (MazeDisplay->objectName().isEmpty())
            MazeDisplay->setObjectName(QString::fromUtf8("MazeDisplay"));
        MazeDisplay->resize(400, 300);
        menuBar = new QMenuBar(MazeDisplay);
        menuBar->setObjectName(QString::fromUtf8("menuBar"));
        MazeDisplay->setMenuBar(menuBar);
        mainToolBar = new QToolBar(MazeDisplay);
        mainToolBar->setObjectName(QString::fromUtf8("mainToolBar"));
        MazeDisplay->addToolBar(mainToolBar);
        centralWidget = new QWidget(MazeDisplay);
        centralWidget->setObjectName(QString::fromUtf8("centralWidget"));
        MazeDisplay->setCentralWidget(centralWidget);
        statusBar = new QStatusBar(MazeDisplay);
        statusBar->setObjectName(QString::fromUtf8("statusBar"));
        MazeDisplay->setStatusBar(statusBar);

        retranslateUi(MazeDisplay);

        QMetaObject::connectSlotsByName(MazeDisplay);
    } // setupUi

    void retranslateUi(QMainWindow *MazeDisplay)
    {
        MazeDisplay->setWindowTitle(QApplication::translate("MazeDisplay", "MazeDisplay", 0, QApplication::UnicodeUTF8));
    } // retranslateUi

};

namespace Ui {
    class MazeDisplay: public Ui_MazeDisplay {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MAZEDISPLAY_H
