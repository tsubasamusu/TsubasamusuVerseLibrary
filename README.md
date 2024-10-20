# 内容
## Device
### プロップを常にプレイヤーの方向に向ける（look_player_prop_manager）
- ``UpdateSpan``：更新頻度
    - 単位は秒
    - 0.0 秒に設定すると正常に動作しなくなる
- ``StartFollowingTrigger``：追従を開始する ``trigger_device``
    - このトリガーを実行したプレイヤーに追従するようになる
- ``StopFollowingTrigger``：追従を停止する ``trigger_device``
    - 追従を停止してから再開するまで ``UpdateSpan`` 以上の時間を空けると安全
- ``TargetPropDataArray``：対象のプロップのデータの配列
    - ``TargetProp``：対象の ``creative_prop``
    - ``RotateYaw``：ヨー軸を回転させるかどうか
    - ``RotatePitch``：ピッチ軸を回転させるかどうか
### タイマー（timer_manager）
- ``StartTimerTrigger``：タイマーを開始する ``trigger_device``
- ``StopTimerTrigger``：タイマーを停止する ``trigger_device``
- ``ResetTimerTrigger``：タイマーをリセットする ``trigger_device``
- ``StopAndHideTimerTrigger``：タイマーを停止して非表示にする ``trigger_device``
- ``TimerHud``：タイマー表示用の ``hud_message_device``
- ``ShowHours``：時間（hh）を表示するかどうか
- ``ShowDecimalFraction``：小数点以下（小数第一位）を表示するかどうか
- ``UpdateDisplayTextOnReset``：リセット時にテキストの表示を初期化するかどうか