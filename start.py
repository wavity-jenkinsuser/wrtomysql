import os
import re
import MySQLdb
import datetime

class Array_vals():
    log_message_list = []
    log_level_list = []
    log_source_list = []
    log_dict_keys = []

def create_table(obj):
    print('Creating table.')
    conn = MySQLdb.connect(user='monitor', passwd='monitor', host='172.16.9.71', port=3306)
    c = conn.cursor()
    c.execute(obj)
    c.close()
    conn.commit()
    conn.close()

def insert_table(obj, obj_list):
    print('Insert in table.')
    conn = MySQLdb.connect(user='monitor', passwd='monitor', host='172.16.9.71', port=3306)
    c = conn.cursor()
    c.executemany(obj, obj_list)
    c.close()
    conn.commit()
    conn.close()

def parse(obj, class_obj=None):
    log_time = int(datetime.datetime.strptime(obj[0][:-3] + '00', '%Y-%m-%dT%H:%M:%S%z').timestamp())
    log_sourse = obj[1].split(sep='.')[0]
    if log_sourse not in class_obj.log_source_list: class_obj.log_source_list.append(log_sourse)
    if log_sourse != 'system': return None
    log_level = obj[1].split(sep='.')[-1]
    if log_level not in class_obj.log_level_list: class_obj.log_level_list.append(log_level)
    log_message = obj[2].split(sep=':')[1][1:]
    if log_message not in class_obj.log_message_list: class_obj.log_message_list.append(log_message)
    log_dict_temp = obj[2].split(sep=':')[2]
    log_dict = {i.split(sep='=')[0]: str((bool(len(i.split(sep='=')) - 1) and i.split(sep='=')[1])) for i in log_dict_temp.split(sep=' ') if i}
    [class_obj.log_dict_keys.append(i) for i in log_dict if i not in class_obj.log_dict_keys]
    log_dict['message'] = log_message
    log_dict['level'] = log_level
    log_dict['timestamp'] = log_time
    return log_dict

def find_and_read_file():
    success = False
    for i in os.listdir('/data/log'):
        x = re.match(r'base\.\d{8}\.log', i)
        if x:
            name = x.group()
            obj = name.split(sep='.')[1]
            print('Working on file /data/logs/{}'.format(name))
            try:
                f = open('/data/log/{}'.format(name, 'r', encoding="latin1"))
                success = main(f.readlines(), obj)
            finally:
                f.close()
            if success:
                print('Success. Remove /data/logs/{}'.format(name))
                os.remove('/data/log/{}'.format(name))


def main(file_reader, obj):
    print('Start main. Parsing')
    c = Array_vals()
    y = ((i.split(sep='{')[0].split(sep='\t')[0], i.split(sep='{')[0].split(sep='\t')[1], i.split(sep='{')[-1].replace('}', '')[:-2]) for i in file_reader)
    y = map(lambda x: parse(x, class_obj=c), y)
    y = filter(None, y)
    y = list(y)

    check = all(y)
    x = [i for i in c.log_dict_keys]
    val_name = ['timestamp', 'level']
    val_name = val_name + x
    num = len(val_name)

    gen_filds = ' '.join([i + ' VARCHAR(50) NULL DEFAULT '',' for i in x][:-1])
    values_name = '(timestamp INT, level VARCHAR(50), ' + gen_filds + ')'

    s = ('%s, ' * num)[:-2]

    create = 'CREATE TABLE IF NOT EXIST router_log_{} {}'.format(obj, values_name)
    insert = 'INSERT INTO router_log_{} {} VALUES ({})'.format(obj, val_name, s)
    
    print('Start DB works. Status: {}. Num objects: {}'.format(str(check), str(len(y))))
    create_table(create)
    insert_table(insert, y)
    print('Done main.')
    return True

if __name__ == '__main__':
    find_and_read_file()
