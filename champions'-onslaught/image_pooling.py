import numpy as np
import cv2
import matplotlib.pyplot as plt
from pathlib import Path
import argparse

def average_pooling(image, pool_size=(2, 2), ceil_mode=True):
    """
    对图像进行平均池化
    
    参数:
        image: 输入图像 (灰度或彩色)
        pool_size: 池化窗口大小 (高度, 宽度)
        ceil_mode: 是否向上取整
    
    返回:
        池化后的图像
    """
    h, w = image.shape[:2]
    pool_h, pool_w = pool_size
    
    # 计算输出尺寸
    if ceil_mode:
        out_h = int(np.ceil(h / pool_h))
        out_w = int(np.ceil(w / pool_w))
    else:
        out_h = h // pool_h
        out_w = w // pool_w
    
    # 根据图像类型处理
    if len(image.shape) == 2:  # 灰度图像
        output = np.zeros((out_h, out_w), dtype=image.dtype)
        for i in range(out_h):
            for j in range(out_w):
                # 获取当前池化窗口
                h_start = i * pool_h
                h_end = min(h_start + pool_h, h)
                w_start = j * pool_w
                w_end = min(w_start + pool_w, w)
                
                # 计算窗口内的平均值
                window = image[h_start:h_end, w_start:w_end]
                output[i, j] = np.mean(window)
    
    else:  # 彩色图像 (BGR或RGB)
        channels = image.shape[2]
        output = np.zeros((out_h, out_w, channels), dtype=image.dtype)
        for i in range(out_h):
            for j in range(out_w):
                h_start = i * pool_h
                h_end = min(h_start + pool_h, h)
                w_start = j * pool_w
                w_end = min(w_start + pool_w, w)
                
                window = image[h_start:h_end, w_start:w_end, :]
                output[i, j] = np.mean(window, axis=(0, 1))
    
    return output

def process_image(input_path, pool_size, num_iterations, output_path=None):
    """
    处理图像：多次进行平均池化
    
    参数:
        input_path: 输入图像路径
        pool_size: 池化窗口大小 (高度, 宽度)
        num_iterations: 池化迭代次数
        output_path: 输出图像路径 (可选)
    
    返回:
        处理后的图像
    """
    # 读取图像
    image = cv2.imread(input_path)
    if image is None:
        print(f"错误：无法读取图像 {input_path}")
        return None
    
    # 转换颜色空间用于显示
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    original_shape = image.shape
    
    # 执行多次池化
    processed_image = image.copy()
    print(f"原始图像尺寸: {original_shape}")
    
    for i in range(num_iterations):
        processed_image = average_pooling(processed_image, pool_size, ceil_mode=True)
        print(f"第 {i+1} 次池化后尺寸: {processed_image.shape}")
    
    # 转换为RGB用于保存和显示
    processed_rgb = cv2.cvtColor(processed_image, cv2.COLOR_BGR2RGB)
    
    # 保存图像
    if output_path:
        cv2.imwrite(output_path, processed_image)
        print(f"处理后的图像已保存到: {output_path}")
    
    return image_rgb, processed_rgb, original_shape, processed_image.shape

def display_results(original, processed, original_shape, processed_shape):
    """
    显示原始图像和处理后的图像
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 6))
    
    # 显示原始图像
    axes[0].imshow(original)
    axes[0].set_title(f'原始图像\n尺寸: {original_shape[:2]}')
    axes[0].axis('off')
    
    # 显示处理后的图像
    axes[1].imshow(processed)
    axes[1].set_title(f'池化后图像\n尺寸: {processed_shape[:2]}\n缩小比例: {original_shape[0]/processed_shape[0]:.1f}x')
    axes[1].axis('off')
    
    plt.tight_layout()
    plt.show()

def main():
    parser = argparse.ArgumentParser(description='图像平均池化处理')
    parser.add_argument('input', help='输入图像路径')
    parser.add_argument('--pool_h', type=int, default=2, help='池化窗口高度')
    parser.add_argument('--pool_w', type=int, default=2, help='池化窗口宽度')
    parser.add_argument('--iterations', type=int, default=1, help='池化迭代次数')
    parser.add_argument('--output', help='输出图像路径')
    
    args = parser.parse_args()
    
    # 设置参数
    pool_size = (args.pool_h, args.pool_w)
    num_iterations = args.iterations
    
    # 处理图像
    original, processed, orig_shape, proc_shape = process_image(
        args.input, 
        pool_size, 
        num_iterations, 
        args.output
    )
    
    if original is not None:
        # 显示结果
        display_results(original, processed, orig_shape, proc_shape)

def interactive_mode():
    """交互式模式"""
    print("=" * 50)
    print("图像平均池化工具")
    print("=" * 50)
    
    # 获取输入文件
    while True:
        input_path = input("请输入图像路径: ").strip()
        if Path(input_path).exists():
            break
        print("文件不存在，请重新输入！")
    
    # 获取池化参数
    pool_h = int(input("请输入池化窗口高度 (默认2): ") or "2")
    pool_w = int(input("请输入池化窗口宽度 (默认2): ") or "2")
    pool_size = (pool_h, pool_w)
    
    # 获取迭代次数
    num_iterations = int(input("请输入池化迭代次数 (默认1): ") or "1")
    
    # 获取输出路径
    output_path = input("请输入输出图像路径 (可选，直接回车跳过): ").strip()
    if not output_path:
        output_path = None
    
    # 处理图像
    original, processed, orig_shape, proc_shape = process_image(
        input_path, 
        pool_size, 
        num_iterations, 
        output_path
    )
    
    if original is not None:
        # 显示结果
        display_results(original, processed, orig_shape, proc_shape)

if __name__ == "__main__":
    # 方式1: 使用命令行参数运行
    # 示例: python image_pooling.py input.jpg --pool_h 2 --pool_w 2 --iterations 2 --output output.jpg
    
    # 方式2: 交互式运行
    main()