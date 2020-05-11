<#
powershellに無いcalコマンドを作成する
利用方法
  PS> scalender.ps1 arg1 arg2
        arg1 : 年を指定
        arg2 : 月を指定
        ※順番は必須。指定しない場合は当月になる
  PS> scalender.ps1 -year arg1 -month arg2
        -year arg1 : 年を指定
        -month arg2 : 月を指定
        ※この場合は、順不同（引数を指定しているので）で、どれか1つの設定も可
          例：   PS> scalender.ps1 -month 5     <=== この場合は、当年の5月を設定
                 PS> scalender.ps1 -year 2019   <=== この場合は、2019年の当月を設定
  PS> scalender.ps1 -D -L -S
        ※指定できるスイッチ
          -D : 指定月の前後含む3ヶ月を表示
          -L : 指定月と翌月、翌々月の3ヶ月を表示
          -S : 指定月と翌月の2か月を表示
          -J : 日本語表示
          -H : 休日情報表示
            スイッチが無い場合は指定月のみ。スイッチは小文字でもOK。
            ただし、Linuxのように複数組み合わせ（例： -DL）指定は不可
  PS> scalender.ps1 -help
        ヘルプ表示

                                           creted by celica 2020/01
#>
Param( 
    [string] $year, 
    [string] $month, 
    [switch] $D, 
    [switch] $L, 
    [switch] $S, 
    [switch] $J, 
    [switch] $H, 
    [switch] $help
)

#pathは、 sholidaylist.ps1が scalender.ps1とおなじpathにあることが前提
$xpath = Split-Path -Parent $MyInvocation.MyCommand.Path
. $xpath/sholidaylist.ps1            #holiday list include

$global:holidaydata = ""

function disptitleyoub($y, $d){
    $yc = $forecolor
    switch($y){
        0   {
            $yc = $hdcolor
            Write-Host $d -BackgroundColor $backcolor -ForegroundColor $yc -NoNewline
        }
        6   {
            $yc = $hdcolor
            Write-Host $d -BackgroundColor $backcolor -ForegroundColor $yc
        }
        default   {
            $yc = $forecolor
            Write-Host $d -BackgroundColor $backcolor -ForegroundColor $yc -NoNewline
        }
    }
}

function dispday($xtd, $xcd){
    #select color
    $xcb=$backcolor
    $xcc=$forecolor
    $xci=$xtd.DayOfWeek.value__
    $xtdd=$xtd.ToString('dd')
    if( $xtd.Month -eq $xcd.Month ){
        switch($xci){
            0 {$xcc = $hdcolor}
            6 {$xcc = $hdcolor}
        }
    } else {
        $xcc=$nccolor
    }

    #holiday check
    $hci = $sholiday.IndexOf($xtd.ToString('M/d'))
    if( ($xtd.Month -eq $xcd.Month) -and ($hci -ge 0) ){
        $xcc = $hdcolor
        $global:holidaydata = $global:holidaydata +"    "+ $sholiday[$hci]+" : "+$sholiday[$hci+1]+"`n"
    }

    #本日の加工
    if( ($xtd.Day -eq (get-date).Day) -and ($xtd.Month -eq (get-date).Month) -and ($xtd.year -eq (get-date).Year)  ){
        $xtdd='<'+$xtdd+'> '    #本日
    } else {
        $xtdd=' '+$xtdd+'  '
    }

    #write
    if($xci -eq 6){
        Write-Host $xtdd -BackgroundColor $xcb -ForegroundColor $xcc
    } else {
        Write-Host $xtdd -BackgroundColor $xcb -ForegroundColor $xcc -NoNewline
    }
}

function disptitle($xcm,$j){
    $xtitle = $xcm.ToString('MMMM', [CultureInfo]::new('en-US'))+" "+$xcm.ToString('yyyy')
    $youb = @("Sun","Mon","Tue","Wed","Thu","Fri","Sat")
    if($j){
        $xtitle = $xcm.ToString('yyyy / MM')
        $youb = @(" 日"," 月"," 火"," 水"," 木"," 金"," 土")
    }
    if( $xcm.month -eq (get-date).month ){
        Write-Host "      << $xtitle >>    " -BackgroundColor $backcolor -ForegroundColor $forecolor
    } else {
        Write-Host "      [[ $xtitle ]]    " -BackgroundColor $backcolor -ForegroundColor $forecolor
    }
    $xyc=0
    foreach($xy in $youb){
        disptitleyoub $xyc $xy"  "
        $xyc++
    }
}

function scalender($xcm, $j){
    disptitle $xcm $j

    $global:holidaydata = "`n"

    #当月1日の曜日から日曜スタート日を算出
    $xcw = $xcm.DayOfWeek.value__
    $xsw = $xcm.adddays(-1*$xcw)

    $xew = $xcm.addmonths(1)

    while( ($xsw -lt $xew) -or ($xsw.DayOfWeek.value__ -ne 0)  ){
        dispday $xsw $xcm
        $xsw = $xsw.adddays(1)
    }

    if($H){
        $global:holidaydata
    } else {
        write-host ""
    }
}

#arg check
function chkarg($year, $month){
    $xyear = $year
    $xmonth = $month
    if( $xyear -eq ""){
        $xyear = (get-date).Year
    }
    if( $xmonth -eq ""){
        $xmonth = (get-date).Month
    }
    $cd=[string]$xyear+"/"+[string]$xmonth+"/01"
    return get-date($cd)
}

function xhelp(){
    $xhtext = "
    利用方法
    PS> scalender.ps1 arg1 arg2
        arg1 : 年を指定
        arg2 : 月を指定
        ※順番は必須。指定しない場合は当月になる

    PS> scalender.ps1 -year arg1 -month arg2
        -year arg1 : 年を指定
        -month arg2 : 月を指定
        ※この場合は、順不同（引数を指定しているので）で、どれか1つの設定も可
            例：   PS> scalender.ps1 -month 5     <=== この場合は、当年の5月を設定
                   PS> scalender.ps1 -year 2019   <=== この場合は、2019年の当月を設定
                    
    PS> scalender.ps1 -D -L -S -J -H
        ※指定できるスイッチ
            -D : 指定月の前後含む3ヶ月を表示
            -L : 指定月と翌月、翌々月の3ヶ月を表示
            -S : 指定月と翌月の2か月を表示
            -J : 日本語表示（デフォルト英語表示）
            -H : 休日情報表示
            スイッチが無い場合は指定月のみ。スイッチは小文字でもOK。
            ただし、Linuxのように複数組み合わせ（例： -DL）指定は不可

    PS> scalender.ps1 -help
        ※ヘルプ（この表示）
                                            creted by celica 2020/01
    "
    $xhtext
}


#### main --------------------
if($help){
    xhelp
    exit 0
}

$cm=chkarg $year $month

$startcnt=0
$endcnt=0
#start cnt
if($D){
    $startcnt=-1
}
#endcnt
if($D -or $S){
    $endcnt=1
}
if($L){
    $endcnt=2
}

for($xc=$startcnt; $xc -le $endcnt; $xc++ ){
    scalender $cm.AddMonths($xc) $J
}
