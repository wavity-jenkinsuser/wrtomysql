import os
import re
import _mysql_exceptions
import MySQLdb
import datetime


class Array_vals():
    log_message_list = []
    log_level_list = []
    log_source_list = []
    log_dict_keys = []


class Count():
    count = 0
    count_create = 0
    count_insert = 0
    count_alter = 0


def work_table(obj):
    print(obj)
    conn = MySQLdb.connect(user='monitor', passwd='monitor', db='monitor', host='172.16.9.71', port=3306)
    c = conn.cursor()
    c.execute(obj)
    c.close()
    conn.commit()
    conn.close()


def parse(obj, class_obj=None):
    def regexp(string):
        x = re.findall(r'=([^\=]*)\"', string)
        y = re.findall(r'=([^\=]*)', string)
        print('REGEXP: ', string)
        print(x)
        print('RAW ALL: ', y)
        for i in x:
            if i: 
                string = string.replace(i, i.replace(' ', '_'))                
        return string
    
    new_col_list = []
    log_time = int(datetime.datetime.strptime(obj[0][:-3] + '00', '%Y-%m-%dT%H:%M:%S%z').timestamp())
    log_sourse = obj[1].split(sep='.')[0]
    if log_sourse not in class_obj.log_source_list: class_obj.log_source_list.append(log_sourse)
    if log_sourse != 'system': return (None, None)
    log_level = obj[1].split(sep='.')[-1]
    if log_level not in class_obj.log_level_list: class_obj.log_level_list.append(log_level)
    log_message = obj[2].split(sep=':')[1][1:]
    if log_message not in class_obj.log_message_list: class_obj.log_message_list.append(log_message)
    log_dict_temp = obj[2].split(sep=':')[2]
    log_dict_temp = regexp(log_dict_temp)
    
    log_dict = {i.split(sep='=')[0]: str((bool(len(i.split(sep='=')) - 1) and bool(len(i.split(sep='=')[1])) and
                                          i.split(sep='=')[1].replace('\"', 'SLASH').replace('\\"', 'SLASH').replace(
                                              '\\', 'SLASH'))) for i in
                log_dict_temp.split(sep=' ') if i}
    [(class_obj.log_dict_keys.append(i), new_col_list.append(i)) for i in log_dict if i not in class_obj.log_dict_keys]
    log_dict['message'] = log_message
    log_dict['level'] = log_level
    log_dict['timestamp'] = log_time
    return (log_dict, new_col_list)


def find_and_read_file():
    success = False
    c = Array_vals()
    for i in os.listdir('/data/log'):
        x = re.match(r'base\.\d{8}\.log', i)
        cc = Count()
        if x:
            name = x.group()
            obj = name.split(sep='.')[1]
            print('Working on file /data/logs/{}'.format(name))
            with open('/data/log/{}'.format(name, 'r', encoding="latin1")) as fileobject:
                for line in fileobject:
                    success = main(line, obj, c, cc)
            if success:
                print('ALL: ', cc.count)
                print('CREATE: ', cc.count_create)
                print('INSERT: ', cc.count_insert)
                print('ALTER: ', cc.count_alter)
                print('Success. Remove /data/logs/{}'.format(name))
                # os.remove('/data/log/{}'.format(name))


def main(file_reader, obj, env, counts):
    c = env
    cc = counts
    cc.count = +1

    y = (file_reader.split(sep='{')[0].split(sep='\t')[0], file_reader.split(sep='{')[0].split(sep='\t')[1],
         file_reader.split(sep='{')[-1].replace('}', '')[:-2])
    y, n_col = parse(y, class_obj=c)

    if not y and not n_col:
        return False

    x = [i for i in c.log_dict_keys]

    gen_filds = ' '.join([i + " VARCHAR(50) DEFAULT 'None'," for i in x])[:-1]
    values_name = '(timestamp INT, level VARCHAR(50), message VARCHAR(50), ' + gen_filds + ')'

    create = 'CREATE TABLE IF NOT EXISTS router_log_{} {}'.format(obj, values_name)
    insert = 'INSERT INTO router_log_{} ({}) VALUES ("{}")'.format(obj, ', '.join(y.keys()),
                                                                   '", "'.join(map(str, y.values())))

    if not cc.count_create:
        work_table(create)
        cc.count_create += 1

    if len(n_col):
        for i in n_col:
            try:
                alter = "ALTER TABLE router_log_{} ADD COLUMN `{}` VARCHAR(50) DEFAULT 'None'".format(obj, i)
                work_table(alter)
                cc.count_alter += 1
            except _mysql_exceptions.OperationalError:
                print('ALTER Fail')
                print(alter)
    try:
        work_table(insert)
    except:
        print('RAW: ', file_reader)
        print('DICT: ', y)
        raise

    cc.count_insert += 1

    return True


if __name__ == '__main__':
    find_and_read_file()
