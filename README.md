# offline-autohatest

## 修改 config.cfg

```
cp config.cfg.temp config.cfg
```

查看并修改config.cfg

## 初始化高可用测试数据

```
./init_sry.sh
```

注意：如果初始化时出错，需要手动清理相关数据

## 执行高可用测试 

```
./ha_test.sh
```
