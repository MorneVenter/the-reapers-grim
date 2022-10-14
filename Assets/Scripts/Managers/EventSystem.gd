extends Node


signal show_glide_wheel(start_percentage: float, duration: float)
signal stop_glide_wheel()

signal show_prompt(prompt_text: String)
signal hide_prompt()

signal start_dialog(actor_name: String, dialog: Array[String], callback: Callable, pitch: float)

signal coins_changed(total: int)

signal zoom_camera()
signal unzoom_camera()
