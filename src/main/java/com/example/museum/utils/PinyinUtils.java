package com.example.museum.utils;

import net.sourceforge.pinyin4j.PinyinHelper;
import net.sourceforge.pinyin4j.format.HanyuPinyinCaseType;
import net.sourceforge.pinyin4j.format.HanyuPinyinOutputFormat;
import net.sourceforge.pinyin4j.format.HanyuPinyinToneType;
import net.sourceforge.pinyin4j.format.exception.BadHanyuPinyinOutputFormatCombination;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 拼音工具类 - 提供汉字转拼音功能
 */
public class PinyinUtils {
    
    private static final Logger logger = LoggerFactory.getLogger(PinyinUtils.class);
    
    /**
     * 将汉字转换为拼音（不带音调）
     * @param chinese 汉字字符串
     * @return 拼音字符串，小写，不带音调
     */
    public static String toPinyin(String chinese) {
        if (chinese == null || chinese.trim().isEmpty()) {
            return "";
        }
        
        // 创建拼音输出格式
        HanyuPinyinOutputFormat format = new HanyuPinyinOutputFormat();
        format.setCaseType(HanyuPinyinCaseType.LOWERCASE); // 小写
        format.setToneType(HanyuPinyinToneType.WITHOUT_TONE); // 不带音调
        
        StringBuilder pinyinBuilder = new StringBuilder();
        char[] chars = chinese.toCharArray();
        
        try {
            for (char c : chars) {
                // 判断是否为汉字
                if (Character.toString(c).matches("[\\u4E00-\\u9FA5]+")) {
                    // 将汉字转为拼音（可能有多音字，取第一个读音）
                    String[] pinyinArray = PinyinHelper.toHanyuPinyinStringArray(c, format);
                    if (pinyinArray != null && pinyinArray.length > 0) {
                        pinyinBuilder.append(pinyinArray[0]);
                    }
                } else {
                    // 非汉字直接保留
                    pinyinBuilder.append(c);
                }
            }
        } catch (BadHanyuPinyinOutputFormatCombination e) {
            logger.error("转换拼音时出错", e);
            return chinese; // 转换出错时返回原始字符串
        }
        
        return pinyinBuilder.toString();
    }
    
    /**
     * 判断一个字符串是否包含另一个字符串的拼音
     * @param source 源字符串
     * @param target 目标字符串（要查找的）
     * @return 如果源字符串的拼音中包含目标字符串，返回true
     */
    public static boolean pinyinContains(String source, String target) {
        if (source == null || target == null || source.trim().isEmpty() || target.trim().isEmpty()) {
            return false;
        }
        
        // 将两个字符串都转为小写拼音
        String sourcePinyin = toPinyin(source).toLowerCase();
        String targetPinyin = toPinyin(target).toLowerCase();
        
        return sourcePinyin.contains(targetPinyin);
    }
}
