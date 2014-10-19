'******************************************************************************
'* File:     comment2name.vbs
'* Purpose:  在PowerDesigner的PDM图形窗口中显示数据列的中文注释
'* Title:    将字段的comment赋值到字段的name中
'* Category: 打开物理模型，运行本脚本（Ctrl+Shift+X）
'* Copyright:foxzz@163.com,2006/07/25 .
'* Author:   foxzz
'* Modified: adeuxy@gmail.com,2014/10/15
'* Version:  1.0
'* Comment:  遍历物理模型中的所有表，将字段的comment赋值到字段的name中。
'            在将name置换为comment过程中，需要考虑的问题
'            1、name必须唯一，而comment有可能不唯一。
'               处理办法是如果字段的comment重复，则字段的name=comment+1、2、3...
'            2、comment值有可能为空，这种情况下对字段的name不处理。
'               针对oracle数据库,将comment on column 字段名称 is '';添加到C:/pdcomment.txt文件中。
'               在补充comment完毕后，便于在数据库中执行  
'            3、针对Oracle数据库，打开32，45，100   
'******************************************************************************
 
Option Explicit 
ValidationMode = True
InteractiveMode = im_Batch
 
Dim system, file
Set system = CreateObject("Scripting.FileSystemObject")
Dim ForReading, ForWriting, ForAppending   '打开文件选项
ForReading   = 1 ' 只读 
ForWriting   = 2 ' 可写 
ForAppending = 8 ' 可写并追加
'打开文本文件
'Set file = system.OpenTextFile("C:/pdcomment.txt", ForWriting, true)
 
 
'判断当前model是否物理数据模型
Dim mdl
Set mdl = ActiveModel 
If (mdl Is Nothing) Then
   MsgBox "处理对象无模型"
ElseIf Not mdl.IsKindOf(PdPDM.cls_Model) Then
   MsgBox "当前模型不是物理数据模型"
Else
   ProcessFolder mdl,file 
End If
'file.Close
 
 
'******************************************************************************
Private sub ProcessFolder(folder,file)
 
Dim i,j,k
i=0:j=0:k=0
 
'列数组，记录字段里不重复的comment
Dim ColumnComment() 
Dim ColumnCommentNumber()
ReDim Preserve ColumnComment(i)
ReDim Preserve ColumnCommentNumber(i)
 
Dim tbl   '当前表
Dim col   '当前字段 
dim curComment  '当前字段comment
 
'处理模型中的表
for each tbl in folder.tables 
    if not tbl.isShortcut then 
       if len(trim(tbl.comment))<>0 then
          '可以在这里显示table的comment
          'tbl.name = tbl.name+"("+trim(tbl.comment)+")"
       end if  
 
       '处理表中的列
       for each col in tbl.columns 
           k = 0
           curComment = trim(col.comment)
           if len(curComment)<>0 then
              '遍历相异的comment数组
              for j = 0 to i
                  if ColumnComment(j) = curComment then
                     '如果找到相同的comment,则相关计数器加1
                     ColumnCommentNumber(j) = ColumnCommentNumber(j) + 1
                     k = j
                  end if 
              Next
              '如果没有相同的comment,则k=0,此时ColumnCommentNumber(0)也为0
              '否则ColumnCommentNumber(k)不为0
              if ColumnCommentNumber(k) <> 0 then
                 col.name = curComment & cstr(ColumnCommentNumber(k))
              else
                 col.name  = curComment
                 'ColumnComment(0)、ColumnCommentNumber(0)永远为空
                 '将相异的comment记录添加到数组中
                 i = i + 1
                 ReDim Preserve ColumnComment(i)
                 ReDim Preserve ColumnCommentNumber(i)
                 ColumnComment(i) = curComment
                 ColumnCommentNumber(i) = 0
              end if
           else
              '写入文件中
              'file.WriteLine "comment on column "+ tbl.name+"."+col.code+" is '';"          
           end if
       next 
    end if 
    '由于不同表的name允许相同,因此此时重新初始化。
    '因为ColumnComment(0)、ColumnCommentNumber(0)为空，可以保留
    ReDim Preserve ColumnComment(0)
    ReDim Preserve ColumnCommentNumber(0)
    i=0:j=0:k=0
 
next
 
Dim view  '当前视图
for each view in folder.Views 
    if not view.isShortcut then 
       '可以在这里显示view的comment
       'view.name =  view.comment
    end if 
next
 
'对子目录进行递归
Dim subpackage 'folder
For Each subpackage In folder.Packages 
    if not subpackage.IsShortcut then 
       ProcessFolder subpackage , file
    end if 
Next
 
end sub
