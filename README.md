#ted-terms

从 XML 提取术语定义。

## 编译

``` bash
npm install -g coffee-script
./build
```

## 用法

### 输出到文件

``` batch
node main.js < sample.xml > output.yaml
```

假定输入文件编码为 GBK，输出文件编码为 UTF-8，终端（控制台）输出编码为 UTF-8。

如果查实所用编码不同，可在 `config.js` 里面设定。

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
