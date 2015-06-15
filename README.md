#ted-terms

从 XML 提取术语定义。

## 用法

输出到文件：

``` batch
node main.js < sample.xml > output.yaml
```

假定输入文件编码为 GBK，输出文件编码为 UTF-16LE。
可在 `config.js` 里面设定。

指定输出格式：

``` batch
node main.js --format=csv < sample.xml > output.csv

node main.js -f json < sample.xml > output.json
```

可选 `csv, json, yaml` 等格式。

调试模式，在控制台查看结果：

``` batch
node main.js --debug < sample.xml

node main.js -d -f json < sample.xml
```
