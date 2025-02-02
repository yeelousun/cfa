import sys

from PySide6.QtCore import QTimer
from PySide6.QtWidgets import (
    QApplication,
    QFileDialog,
    QHBoxLayout,
    QLineEdit,
    QListWidget,
    QMainWindow,
    QMessageBox,
    QProgressBar,
    QPushButton,
    QSizePolicy,
    QTableWidget,
    QTableWidgetItem,
    QTextEdit,
    QVBoxLayout,
    QWidget,
)


class CollapsibleWidget(QWidget):
    """
    自定义可折叠控件：
    标题按钮点击后，可显示/隐藏内部的内容区域
    """

    def __init__(self, title="", parent=None):
        super().__init__(parent)
        self.toggle_button = QPushButton(title)
        self.toggle_button.setCheckable(True)
        self.toggle_button.setChecked(True)
        self.toggle_button.clicked.connect(self.on_toggle)

        # 内容区域，用于放置内部的子控件
        self.content_area = QWidget()
        self.content_layout = QVBoxLayout(self.content_area)
        self.content_layout.setContentsMargins(0, 0, 0, 0)

        main_layout = QVBoxLayout(self)
        main_layout.addWidget(self.toggle_button)
        main_layout.addWidget(self.content_area)
        main_layout.setContentsMargins(0, 0, 0, 0)
        self.setLayout(main_layout)

    def on_toggle(self):
        if self.toggle_button.isChecked():
            self.content_area.show()
        else:
            self.content_area.hide()


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("PySide6 示例")
        # 设置主窗口大小
        self.resize(600, 600)

        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        main_layout.setSpacing(10)

        # 上部区域（可折叠）
        self.top_area = CollapsibleWidget("上部区域（文件操作）")
        main_layout.addWidget(self.top_area)
        self.init_top_area()

        # 下部区域（可折叠）
        self.bottom_area = CollapsibleWidget("下部区域（搜索与回复）")
        main_layout.addWidget(self.bottom_area)
        self.init_bottom_area()

    def init_top_area(self):
        """
        初始化上部区域的控件：
          - “选择文件”按钮（只允许选择图像文件，多选）
          - 显示选择的文件路径的列表
          - 进度条及“执行”按钮，点击后模拟进度更新
        """
        layout = self.top_area.content_layout

        # 1. 选择文件按钮
        self.select_file_button = QPushButton("选择文件")
        layout.addWidget(self.select_file_button)
        self.select_file_button.clicked.connect(self.select_files)

        # 2. 显示文件地址的区域（使用 QListWidget 进行显示）
        self.file_list = QListWidget()
        layout.addWidget(self.file_list)

        # 3. 进度条和执行按钮（水平布局）
        h_layout = QHBoxLayout()
        self.progress_bar = QProgressBar()
        self.progress_bar.setValue(0)
        h_layout.addWidget(self.progress_bar)

        self.execute_button = QPushButton("执行")
        h_layout.addWidget(self.execute_button)
        self.execute_button.clicked.connect(self.execute_task)

        layout.addLayout(h_layout)

    def init_bottom_area(self):
        """
        初始化下部区域的控件：
          - 输入文字的对话框和右边的搜索按钮（水平布局）
          - 搜索后显示回复内容（只读的 QTextEdit）和一个三列的列表（使用 QTableWidget）
          - 点击表格中的一行会显示详细的文字内容
        """
        layout = self.bottom_area.content_layout

        # 输入文字对话框与搜索按钮
        input_layout = QHBoxLayout()
        self.input_text = QLineEdit()
        self.input_text.setPlaceholderText("请输入搜索内容...")
        input_layout.addWidget(self.input_text)

        self.search_button = QPushButton("搜索")
        input_layout.addWidget(self.search_button)
        self.search_button.clicked.connect(self.search_action)
        layout.addLayout(input_layout)

        # 回复对话框（只读文本）
        self.reply_text = QTextEdit()
        self.reply_text.setPlaceholderText("回复内容将显示在这里...")
        self.reply_text.setReadOnly(True)
        layout.addWidget(self.reply_text)

        # 三列的列表，显示搜索结果（使用 QTableWidget）
        self.table = QTableWidget(0, 3)
        self.table.setHorizontalHeaderLabels(["列1", "列2", "列3"])
        self.table.horizontalHeader().setStretchLastSection(True)
        layout.addWidget(self.table)

        # 表格单元格点击事件，显示详细内容
        self.table.cellClicked.connect(self.show_detail)

    def select_files(self):
        """
        打开文件选择对话框，只允许选择图像文件，支持多选。
        选中文件后，在文件列表中显示文件路径
        """
        file_paths, _ = QFileDialog.getOpenFileNames(
            self, "选择图像文件", "", "Image Files (*.png *.jpg *.jpeg *.bmp *.gif)"
        )
        if file_paths:
            self.file_list.clear()
            self.file_list.addItems(file_paths)

    def execute_task(self):
        """
        模拟执行任务，使用 QTimer 定时更新进度条。
        """
        self.progress_bar.setValue(0)
        self.progress = 0
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_progress)
        self.timer.start(100)  # 每 100 毫秒更新一次

    def update_progress(self):
        self.progress += 5
        if self.progress > 100:
            self.timer.stop()
            self.progress_bar.setValue(100)
        else:
            self.progress_bar.setValue(self.progress)

    def search_action(self):
        """
        点击搜索按钮后，读取输入框内容，更新回复文本和表格数据。
        这里为了示例，模拟生成 5 行搜索结果数据。
        """
        text = self.input_text.text().strip()
        if not text:
            QMessageBox.warning(self, "提示", "请输入搜索内容！")
            return

        # 更新回复内容
        self.reply_text.setText(f"搜索结果：回复内容展示 —— {text}")

        # 模拟搜索结果填充表格数据
        self.table.setRowCount(0)
        for i in range(5):
            row_position = self.table.rowCount()
            self.table.insertRow(row_position)
            # 这里每列填入一些示例数据
            item1 = QTableWidgetItem(f"值1_{i}")
            item2 = QTableWidgetItem(f"值2_{i}")
            item3 = QTableWidgetItem(f"值3_{i}")
            self.table.setItem(row_position, 0, item1)
            self.table.setItem(row_position, 1, item2)
            self.table.setItem(row_position, 2, item3)

    def show_detail(self, row, column):
        """
        当点击表格中的任一单元格时，获取该行数据，并以对话框形式显示详细内容。
        """
        value1 = self.table.item(row, 0).text() if self.table.item(row, 0) else ""
        value2 = self.table.item(row, 1).text() if self.table.item(row, 1) else ""
        value3 = self.table.item(row, 2).text() if self.table.item(row, 2) else ""
        detail = f"详细内容：\n列1: {value1}\n列2: {value2}\n列3: {value3}"
        QMessageBox.information(self, "详细信息", detail)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
