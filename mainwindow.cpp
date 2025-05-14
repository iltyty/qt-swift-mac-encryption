#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "BiometricBridge.h"

static MainWindow* g_instance = nullptr;

static void onEncryptResultBridge(const char* result) {
    if (g_instance) {
        g_instance->onEncryptResult(result);
    }
}

static void onDecryptResultBridge(const char* result) {
    if (g_instance) {
        g_instance->onDecryptResult(result);
    }
}

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    
    g_instance = this;

    connect(ui->encryptButton, &QPushButton::clicked, this, [this]() {
        QString text = ui->inputField->text();
        authenticateAndEncryptBridge(text.toUtf8().data(), onEncryptResultBridge);
    });

    connect(ui->decryptButton, &QPushButton::clicked, this, [this]() {
        QString text = ui->inputField->text();
        authenticateAndDecryptBridge(text.toUtf8().data(), onDecryptResultBridge);
    });
}

void MainWindow::onEncryptResult(const char *result) {
    if (result) {
        qDebug() << "encryption result: " << result;
        QMetaObject::invokeMethod(QApplication::instance(), [=]() {
            ui->resultLabel->setText(result);
        });
    }
}

void MainWindow::onDecryptResult(const char *result) {
    if (result) {
        qDebug() << "decryption result: " << result;
        QMetaObject::invokeMethod(QApplication::instance(), [=]() {
            ui->resultLabel->setText(result);
        });
    }
}

MainWindow::~MainWindow()
{
    delete ui;
}
