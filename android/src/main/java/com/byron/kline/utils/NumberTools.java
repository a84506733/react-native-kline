package com.byron.kline.utils;

import android.text.TextUtils;

import java.math.BigDecimal;

/*************************************************************************
 * Description   :
 *
 * @PackageName  : com.byron.kline.utils
 * @FileName     : NumberTools.java
 * @Author       : chao
 * @Date         : 2019/4/8
 * @Email        : icechliu@gmail.com
 * @version      : V1
 *************************************************************************/
public class NumberTools {


    /**
     * 规范小数  向下取整
     *
     * @param num
     * @param len
     * @return
     */
    public static String roundDown(double num, int len) {
        return roundDown(new BigDecimal(num), len);
    }

    public static String roundDown(BigDecimal num, int len) {
        String strTemp = "";
        try {
            String string = num.setScale(len + 2, BigDecimal.ROUND_HALF_UP).toPlainString();
            return new BigDecimal(string).setScale(len, BigDecimal.ROUND_DOWN).toPlainString();
        } catch (Exception ex) {
            strTemp = "";
        }

        return strTemp;
    }

    /**
     * 买卖盘的数量折合
     *
     * @param amount
     * @return
     */
    public static String formatAmount(String amount) {

        if (TextUtils.isEmpty(amount)) {
            return "0";
        } else {
            BigDecimal amountBigDecimal = new BigDecimal(amount);
            String tAmoutString = amountBigDecimal.toPlainString();
            if (new BigDecimal(amount).compareTo(BigDecimal.ONE) < 0) {

                if (tAmoutString.length() > 5) {
                    String temp = tAmoutString.substring(0, 5);
                    if (new BigDecimal(temp).compareTo(BigDecimal.ZERO) > 0) {
                        return temp;
                    } else {
                        return "0";
                    }
                } else {
                    return tAmoutString;
                }
            } else if (amountBigDecimal.compareTo(new BigDecimal(1000)) < 0) {
                if (tAmoutString.length() > 5) {
                    return tAmoutString.substring(0, 5);
                } else {
                    return tAmoutString;
                }
            } else if (amountBigDecimal.compareTo(new BigDecimal(1000000)) < 0) {
                BigDecimal tAmountBigDecimal = amountBigDecimal.divide(new BigDecimal(1000));
                tAmoutString = tAmountBigDecimal.stripTrailingZeros().toPlainString();
                if (tAmoutString.length() > 4) {
                    String sub = tAmoutString.substring(0, 4);
                    if (sub.endsWith(".")) {//如果截取前四位后的数值最后一位是"."，则只截取前三位
                        return tAmoutString.substring(0, 3) + "K";
                    } else {
                        return tAmoutString.substring(0, 4) + "K";
                    }
                } else {
                    return tAmountBigDecimal.toPlainString() + "K";
                }
            } else if (amountBigDecimal.compareTo(new BigDecimal(1000000000)) < 0) {

                BigDecimal tAmountBigDecimal = amountBigDecimal.divide(new BigDecimal(1000000));
                tAmoutString = tAmountBigDecimal.stripTrailingZeros().toPlainString();
                if (tAmoutString.length() > 4) {
                    String sub = tAmoutString.substring(0, 4);
                    if (sub.endsWith(".")) {
                        return tAmoutString.substring(0, 3) + "M";
                    } else {
                        return tAmoutString.substring(0, 4) + "M";
                    }
                } else {
                    return tAmountBigDecimal.toPlainString() + "M";
                }
            } else {
                BigDecimal tAmountBigDecimal = amountBigDecimal.divide(new BigDecimal(1000000000));
                tAmoutString = tAmountBigDecimal.stripTrailingZeros().toPlainString();
                if (tAmoutString.length() > 4) {
                    String sub = tAmoutString.substring(0, 4);
                    if (sub.endsWith(".")) {
                        return tAmoutString.substring(0, 3) + "B";
                    } else {
                        return tAmoutString.substring(0, 4) + "B";
                    }
                } else {
                    return tAmountBigDecimal.toPlainString() + "B";
                }
            }
        }
    }

    /**
     * 修改小数显示格式
     * */
    public static String formatDecimal(Object num) {
        String temp;
        if (num instanceof String) {
            temp = (String) num;
        } else if (num instanceof Number) {
            temp = new BigDecimal(num.toString()).toString();
        } else {
            return String.valueOf(num); // Handle other types as string
        }

        String[] arr = temp.split("\\."); // Split by literal dot
        if (arr.length != 2) {
            return temp;
        } else {
            int count = 0;
            for (int i = 0; i < arr[1].length(); i++) {
                if (arr[1].charAt(i) != '0') {
                    break;
                } else {
                    count++;
                }
            }

            if (count > 2) {
                String lastStr = "";
                if (arr[1].length() > count) {
                    lastStr = arr[1].substring(count, Math.min(count + 4, arr[1].length()));
                }
                return arr[0] + ".0{" + count + "}" + lastStr;
            } else {
                String lastStr = "";
                if (arr[1].length() > count) {
                    lastStr = arr[1].substring(0, Math.min(count + 4, arr[1].length()));
                }
                return arr[0] + "." + lastStr;
            }
        }
    }
}
