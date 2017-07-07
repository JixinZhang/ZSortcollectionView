# ZSortCollectionView
可拖动排序的CollectionView

##写在前面的话:
1. ZSortCollectionView的代码主要是参考（其实是抄袭）wazrx写的[XWDragCellCollectionView](https://github.com/wazrx/XWDragCellCollectionView)
2. 对XWDragCellCollectionView做了一些扩展和更改：
	* 设定，是否可以在不同section之间拖动cell；
	* 设定，是否只有section0才可以拖动；
	* 设定，当限定只能在section内移动cell时，是否将cell的拖动空间限定在section内
	* 增加，点击cell中的添加／删除按钮可以将cell移动到指定的位置
	* 更改，将XWDragCellCollectionView中使用的`UILongPressGestureRecognizer`更改为`UIPanGestureRecognizer`

## 