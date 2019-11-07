import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * fileName: FileFormat
 * description: mysql 导入文件格式整理
 * author: lx
 * createTime: 2019/11/6 11:20
 */

public class FileFormat {

    public static void main(String[] args) {
        String path = "/Users/rjia/Documents/GitHub/cCode/src/main/java/resources/data.txt";
        List<List<String>> result = getDataFromFile(path);

        System.out.println(result.toString());
    }

    public static List<List<String>> getDataFromFile(String path) {
        List<List<String>> result = new ArrayList<List<String>>();
        BufferedReader br = null;
        FileReader fileReader = null;
        try {
            String record = null;

            fileReader = new FileReader(path);
            br = new BufferedReader(fileReader);

            while ((record = br.readLine()) != null) {
                List<String> lineItems = Arrays.asList(record.split("\\|"));
                result.add(lineItems);
            }
            result.remove(0);
            result.remove(result.size() - 1);

        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                br.close();
                fileReader.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return result;
    }
}