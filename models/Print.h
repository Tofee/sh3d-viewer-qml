// Print.h
#ifndef PRINT_H
#define PRINT_H

#include <QAbstractListModel>
#include <QObject>

class Print : public QAbstractListModel {
    Q_OBJECT
public:
    explicit Print(QObject *parent = nullptr);
    // Minimal model overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return 0; }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }
    QHash<int, QByteArray> roleNames() const override { return QHash<int, QByteArray>(); }

    // Attributes from DTD
    Q_PROPERTY(QString headerFormat READ headerFormat WRITE setHeaderFormat NOTIFY headerFormatChanged)
    Q_PROPERTY(QString footerFormat READ footerFormat WRITE setFooterFormat NOTIFY footerFormatChanged)
    Q_PROPERTY(QString planScale READ planScale WRITE setPlanScale NOTIFY planScaleChanged)
    Q_PROPERTY(bool furniturePrinted READ furniturePrinted WRITE setFurniturePrinted NOTIFY furniturePrintedChanged)
    Q_PROPERTY(bool planPrinted READ planPrinted WRITE setPlanPrinted NOTIFY planPrintedChanged)
    Q_PROPERTY(bool view3DPrinted READ view3DPrinted WRITE setView3DPrinted NOTIFY view3DPrintedChanged)
    Q_PROPERTY(int paperWidth READ paperWidth WRITE setPaperWidth NOTIFY paperWidthChanged)
    Q_PROPERTY(int paperHeight READ paperHeight WRITE setPaperHeight NOTIFY paperHeightChanged)
    Q_PROPERTY(int paperTopMargin READ paperTopMargin WRITE setPaperTopMargin NOTIFY paperTopMarginChanged)
    Q_PROPERTY(int paperLeftMargin READ paperLeftMargin WRITE setPaperLeftMargin NOTIFY paperLeftMarginChanged)
    Q_PROPERTY(int paperBottomMargin READ paperBottomMargin WRITE setPaperBottomMargin NOTIFY paperBottomMarginChanged)
    Q_PROPERTY(int paperRightMargin READ paperRightMargin WRITE setPaperRightMargin NOTIFY paperRightMarginChanged)
    Q_PROPERTY(QString paperOrientation READ paperOrientation WRITE setPaperOrientation NOTIFY paperOrientationChanged)

    // Getters/Setters (inline)
    QString headerFormat() const { return m_headerFormat; }
    void setHeaderFormat(const QString &v) { if (m_headerFormat != v) { m_headerFormat = v; emit headerFormatChanged(); } }
    QString footerFormat() const { return m_footerFormat; }
    void setFooterFormat(const QString &v) { if (m_footerFormat != v) { m_footerFormat = v; emit footerFormatChanged(); } }
    QString planScale() const { return m_planScale; }
    void setPlanScale(const QString &v) { if (m_planScale != v) { m_planScale = v; emit planScaleChanged(); } }
    bool furniturePrinted() const { return m_furniturePrinted; }
    void setFurniturePrinted(bool v) { if (m_furniturePrinted != v) { m_furniturePrinted = v; emit furniturePrintedChanged(); } }
    bool planPrinted() const { return m_planPrinted; }
    void setPlanPrinted(bool v) { if (m_planPrinted != v) { m_planPrinted = v; emit planPrintedChanged(); } }
    bool view3DPrinted() const { return m_view3DPrinted; }
    void setView3DPrinted(bool v) { if (m_view3DPrinted != v) { m_view3DPrinted = v; emit view3DPrintedChanged(); } }
    int paperWidth() const { return m_paperWidth; }
    void setPaperWidth(int v) { if (m_paperWidth != v) { m_paperWidth = v; emit paperWidthChanged(); } }
    int paperHeight() const { return m_paperHeight; }
    void setPaperHeight(int v) { if (m_paperHeight != v) { m_paperHeight = v; emit paperHeightChanged(); } }
    int paperTopMargin() const { return m_paperTopMargin; }
    void setPaperTopMargin(int v) { if (m_paperTopMargin != v) { m_paperTopMargin = v; emit paperTopMarginChanged(); } }
    int paperLeftMargin() const { return m_paperLeftMargin; }
    void setPaperLeftMargin(int v) { if (m_paperLeftMargin != v) { m_paperLeftMargin = v; emit paperLeftMarginChanged(); } }
    int paperBottomMargin() const { return m_paperBottomMargin; }
    void setPaperBottomMargin(int v) { if (m_paperBottomMargin != v) { m_paperBottomMargin = v; emit paperBottomMarginChanged(); } }
    int paperRightMargin() const { return m_paperRightMargin; }
    void setPaperRightMargin(int v) { if (m_paperRightMargin != v) { m_paperRightMargin = v; emit paperRightMarginChanged(); } }
    QString paperOrientation() const { return m_paperOrientation; }
    void setPaperOrientation(const QString &v) { if (m_paperOrientation != v) { m_paperOrientation = v; emit paperOrientationChanged(); } }

signals:
    void headerFormatChanged();
    void footerFormatChanged();
    void planScaleChanged();
    void furniturePrintedChanged();
    void planPrintedChanged();
    void view3DPrintedChanged();
    void paperWidthChanged();
    void paperHeightChanged();
    void paperTopMarginChanged();
    void paperLeftMarginChanged();
    void paperBottomMarginChanged();
    void paperRightMarginChanged();
    void paperOrientationChanged();

private:
    QString m_headerFormat;
    QString m_footerFormat;
    QString m_planScale;
    bool m_furniturePrinted = true;
    bool m_planPrinted = true;
    bool m_view3DPrinted = true;
    int m_paperWidth = 0;
    int m_paperHeight = 0;
    int m_paperTopMargin = 0;
    int m_paperLeftMargin = 0;
    int m_paperBottomMargin = 0;
    int m_paperRightMargin = 0;
    QString m_paperOrientation;
};

#endif // PRINT_H
