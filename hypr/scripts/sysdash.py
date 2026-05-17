#!/usr/bin/env python3

import curses
import os
import shutil
import time


def read_cpu_times():
    with open("/proc/stat", "r", encoding="utf-8") as f:
        parts = f.readline().split()
    values = list(map(int, parts[1:]))
    idle = values[3] + values[4]
    total = sum(values)
    return idle, total


def get_cpu_percent(prev):
    current = read_cpu_times()
    if prev is None:
        return 0, current
    prev_idle, prev_total = prev
    idle, total = current
    idle_delta = idle - prev_idle
    total_delta = total - prev_total
    if total_delta <= 0:
        return 0, current
    percent = int(round(100 * (total_delta - idle_delta) / total_delta))
    return max(0, min(100, percent)), current


def get_mem_info():
    total = 0
    available = 0
    with open("/proc/meminfo", "r", encoding="utf-8") as f:
        for line in f:
            if line.startswith("MemTotal:"):
                total = int(line.split()[1])
            elif line.startswith("MemAvailable:"):
                available = int(line.split()[1])
    used = total - available
    used_gib = used / 1024 / 1024
    total_gib = total / 1024 / 1024
    percent = int(round((used / total) * 100)) if total else 0
    return used_gib, total_gib, percent


def get_temp_c():
    candidates = []
    for root in ("/sys/class/hwmon", "/sys/class/thermal"):
        if not os.path.isdir(root):
            continue
        for entry in os.listdir(root):
            if root.endswith("hwmon"):
                path = os.path.join(root, entry, "temp1_input")
            else:
                path = os.path.join(root, entry, "temp")
            if os.path.exists(path):
                candidates.append(path)
    for path in candidates:
        try:
            with open(path, "r", encoding="utf-8") as f:
                raw = int(f.read().strip())
            return raw // 1000 if raw > 1000 else raw
        except Exception:
            continue
    return 0


def get_disk_info():
    usage = shutil.disk_usage("/")
    used_gib = int(usage.used / 1024 / 1024 / 1024)
    total_gib = int(usage.total / 1024 / 1024 / 1024)
    percent = int(round((usage.used / usage.total) * 100)) if usage.total else 0
    return used_gib, total_gib, percent


def read_net_bytes():
    rx = 0
    tx = 0
    with open("/proc/net/dev", "r", encoding="utf-8") as f:
        lines = f.readlines()[2:]
    for line in lines:
        iface, data = line.split(":", 1)
        iface = iface.strip()
        if iface == "lo":
            continue
        fields = data.split()
        rx += int(fields[0])
        tx += int(fields[8])
    return rx, tx


def format_rate(rate):
    units = ["B/s", "KB/s", "MB/s", "GB/s"]
    value = float(rate)
    idx = 0
    while value >= 1024 and idx < len(units) - 1:
        value /= 1024
        idx += 1
    if idx == 0:
        return f"{int(value)} {units[idx]}"
    return f"{value:.1f} {units[idx]}"


def progress_bar(width, percent):
    filled = int((width * percent) / 100)
    return "█" * filled + "░" * max(0, width - filled)


def draw_box(stdscr, y, x, h, w, title, value, subvalue, percent, color_pair):
    stdscr.attron(curses.color_pair(1))
    stdscr.addstr(y, x, "╭" + "─" * (w - 2) + "╮")
    for row in range(1, h - 1):
        stdscr.addstr(y + row, x, "│")
        stdscr.addstr(y + row, x + w - 1, "│")
    stdscr.addstr(y + h - 1, x, "╰" + "─" * (w - 2) + "╯")
    stdscr.attroff(curses.color_pair(1))

    stdscr.attron(curses.color_pair(2))
    stdscr.addstr(y + 1, x + 2, title[: w - 4])
    stdscr.attroff(curses.color_pair(2))

    bar_width = max(10, w - 6)
    stdscr.attron(curses.color_pair(color_pair))
    stdscr.addstr(y + 3, x + 2, progress_bar(bar_width, percent)[:bar_width])
    stdscr.attroff(curses.color_pair(color_pair))

    stdscr.attron(curses.color_pair(3))
    stdscr.addstr(y + h - 3, x + 2, value[: w - 4])
    stdscr.attroff(curses.color_pair(3))

    stdscr.attron(curses.color_pair(4))
    stdscr.addstr(y + h - 2, x + 2, subvalue[: w - 4])
    stdscr.attroff(curses.color_pair(4))


def main(stdscr):
    curses.curs_set(0)
    stdscr.nodelay(True)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, 252, -1)
    curses.init_pair(2, 223, -1)
    curses.init_pair(3, 224, -1)
    curses.init_pair(4, 245, -1)
    curses.init_pair(5, 217, -1)
    curses.init_pair(6, 153, -1)
    curses.init_pair(7, 186, -1)
    curses.init_pair(8, 151, -1)

    prev_cpu = None
    prev_net = read_net_bytes()
    prev_time = time.time()

    while True:
        now = time.time()
        dt = max(0.5, now - prev_time)
        prev_time = now

        cpu_percent, prev_cpu = get_cpu_percent(prev_cpu)
        mem_used, mem_total, mem_percent = get_mem_info()
        temp_c = get_temp_c()
        disk_used, disk_total, disk_percent = get_disk_info()
        rx_now, tx_now = read_net_bytes()
        rx_rate = int((rx_now - prev_net[0]) / dt)
        tx_rate = int((tx_now - prev_net[1]) / dt)
        prev_net = (rx_now, tx_now)

        stdscr.erase()
        height, width = stdscr.getmaxyx()

        if height < 20 or width < 76:
            stdscr.addstr(1, 2, "Agrandar la ventana para ver el dashboard.")
            stdscr.refresh()
            key = stdscr.getch()
            if key in (ord("q"), 27):
                break
            time.sleep(0.2)
            continue

        stdscr.attron(curses.color_pair(2))
        stdscr.addstr(1, 3, "System Dashboard")
        stdscr.attroff(curses.color_pair(2))
        stdscr.attron(curses.color_pair(4))
        stdscr.addstr(1, width - 20, "q / Esc para salir")
        stdscr.attroff(curses.color_pair(4))

        card_w = (width - 10) // 3
        top_y = 3
        draw_box(stdscr, top_y, 3, 7, card_w, "CPU", f"{cpu_percent}%", "uso actual", cpu_percent, 5)
        draw_box(stdscr, top_y, 4 + card_w, 7, card_w, "RAM", f"{mem_used:.1f}G / {mem_total:.1f}G", f"{mem_percent}% en uso", mem_percent, 6)
        temp_percent = max(0, min(100, int(temp_c)))
        draw_box(stdscr, top_y, 5 + card_w * 2, 7, card_w, "TEMP", f"{temp_c}°C", "temperatura", temp_percent, 7)

        bottom_y = 11
        draw_box(stdscr, bottom_y, 3, 7, card_w + 6, "DISK", f"{disk_used}G / {disk_total}G", f"{disk_percent}% ocupado", disk_percent, 5)
        net_percent = max(1, min(100, int((rx_rate + tx_rate) / 1024 / 1024 * 8)))
        draw_box(stdscr, bottom_y, 10 + card_w + 1, 7, card_w * 2 - 4, "NET", f"↓ {format_rate(rx_rate)}", f"↑ {format_rate(tx_rate)}", net_percent, 8)

        stdscr.refresh()
        for _ in range(10):
            key = stdscr.getch()
            if key in (ord("q"), 27):
                return
            time.sleep(0.1)


if __name__ == "__main__":
    curses.wrapper(main)
