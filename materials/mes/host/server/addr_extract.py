import re

def extract_and_save_to_csv(input_file, output_file='./data.csv'):
    """
    从文本文件中提取 --1************ 和 --2************ 之间的内容,
    并保存为CSV文件
    
    参数:
        input_file: 输入文本文件的路径
        output_file: 输出CSV文件的路径,默认为 'data.csv'
    """
    try:
        # 读取文件内容
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 使用正则表达式提取 --1************ 和 --2************ 之间的内容
        pattern = r'--1\*+\s*(.*?)\s*--2\*+'
        match = re.search(pattern, content, re.DOTALL)
        
        if match:
            # 获取匹配的内容
            extracted_text = match.group(1).strip()
            
            # 将提取的内容保存为CSV文件
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(extracted_text)
            
            print(f"成功提取内容并保存到 {output_file}")
            print(f"提取的内容:\n{extracted_text}")
        else:
            print("未找到匹配的内容")
    
    except FileNotFoundError:
        print(f"错误: 找不到文件 '{input_file}'")
    except Exception as e:
        print(f"发生错误: {e}")


# 使用示例
if __name__ == "__main__":
    # 替换为你的实际文件路径
    input_filename = '../log'
    
    extract_and_save_to_csv(input_filename)