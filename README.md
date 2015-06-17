#ted-terms

从 XML 提取术语定义。

## 编译

``` bash
npm install -g coffee-script
./build
```

## 用法

1.  双击 `shell.bat` 打开 Windows 命令行窗口。

2.  输入命令 `run.bat` 检查脚本能否正确处理样例输入 `sample.xml`。
    如转换出错或记事本内结果显示为乱码，请参考下文修改编码设定。

3.  使用以下命令提取术语定义，并输出为所需格式的文本。

### 输出到文件

``` batch
node main.js < sample.xml > output.yaml
```

假定输入文件编码为 GBK，输出文件编码为 UTF-8，终端（控制台）输出编码为 UTF-8。

如果查实输入文件所用编码不同，可编辑 `config.js` 修改设定。

### 指定输出格式

可选 `csv, json, yaml` 等格式。

``` batch
node main.js --format=csv < sample.xml > output.csv

node main.js -f json < sample.xml > output.json
```

YAML 格式适合直接用记事本打开查看。

以 GBK 编码输出的 CSV 文件可作为电子表格导入 Excel。

### 调试模式

在控制台查看结果：

``` batch
node main.js --debug < sample.xml

node main.js -d -f json < sample.xml
```
